//
//  CLAlert.m
//  MacUpdater
//
//  Created by Carterhaugh LLC on 8/15/23.
//  Copyright © 2023 CoreCode Limited. All rights reserved.
//

#import "CLAlert.h"

#import "CLCoreLib.h"
#import "CLGlobals.h"
#import "CLMakers.h"
#import "CLLogging.h"
#import "CLEnvironment.h"
#import "CLConfiguration.h"
#import "CLConvenience.h"
#import "CLFakeAlertWindow.h"

#import "Foundation+CoreCode.h"

#ifdef USE_LAM
#import "NSData+LAMCompression.h"
#endif

#if CL_TARGET_IOS || CL_TARGET_OSX
void alert_feedback(NSString *usermsg, NSString *details, BOOL fatal)
{
    cc_log_error(@"alert_feedback %@ %@", usermsg, details);

    dispatch_block_t block = ^
    {
        static const int maxLen = 400;

        NSString *encodedPrefs = @"";
        
        [NSUserDefaults.standardUserDefaults synchronize];
        
#if CL_TARGET_OSX
        NSData *prefsData = cc.prefsURL.contents;
        
#ifdef USE_LAM
        prefsData = [prefsData lam_compressedDataUsingCompression:LAMCompressionZLIB];
#endif
        
        encodedPrefs = [prefsData base64EncodedStringWithOptions:(NSDataBase64EncodingOptions)0];

#ifndef SANDBOX
        if ((cc.appCrashLogFilenames).count)
        {
            NSString *crashes = [cc.appCrashLogs joined:@"\n"];
            encodedPrefs = [encodedPrefs stringByAppendingString:@"\n\n"];
            encodedPrefs = [encodedPrefs stringByAppendingString:crashes];
        }
#endif
#endif
        
        NSString *visibleDetails = details;
        if (visibleDetails.length > maxLen)
            visibleDetails = makeString(@"%@  …\n(Remaining message omitted)", [visibleDetails clamp:maxLen]);
        NSString *message = makeString(@"%@\n\n You can contact our support with detailed information so that we can fix this problem.\n\nInformation: %@", usermsg, visibleDetails);
        NSString *mailtoLink = @"";
        @try
        {
            NSString *appName = cc.appName;
            NSString *licenseCode = cc.appChecksumIncludingFrameworksSHA;
            NSString *udid = @"N/A";

        #if defined(USE_SECURITY) && defined(USE_IOKIT)
            Class hostInfoClass = NSClassFromString(@"JMHostInformation");
            if (hostInfoClass)
            {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wundeclared-selector"
                NSString *macAddress = [hostInfoClass performSelector:@selector(macAddress)];
        #pragma clang diagnostic pop
                udid = macAddress.SHA1;
            }
        #endif
            
            if ([NSApp.delegate respondsToSelector:@selector(customSupportRequestAppName)])
                appName = [NSApp.delegate performSelector:@selector(customSupportRequestAppName)];
            if ([NSApp.delegate respondsToSelector:@selector(customSupportRequestLicense)])
                licenseCode = [NSApp.delegate performSelector:@selector(customSupportRequestLicense)];
            
            mailtoLink = makeString(@"mailto:%@?subject=%@ v%@ (%i) Problem Report&body=Hello\nA %@ error in %@ occurred (%@).\n\nBye\n\nP.S. Details: %@\n\n\nP.P.S: Hardware: %@ Software: %@ UDID: %@ Admin: %i\n\nPreferences: %@\n",
                                                kFeedbackEmail,
                                                appName,
                                                cc.appVersionString,
                                                cc.appBuildNumber,
                                                fatal ? @"fatal" : @"",
                                                cc.appName,
                                                usermsg,
                                                details,
                                                _machineType(),
                                                NSProcessInfo.processInfo.operatingSystemVersionString,
                                                makeString(@"%@ %@", licenseCode, udid),
                                                _isUserAdmin(),
                                                encodedPrefs);

        }
        @catch (NSException *)
        {
        }


#if defined(USE_CRASHHELPER) && USE_CRASHHELPER
        if (fatal)
        {
            NSString *title = makeString(@"%@ Fatal Error", cc.appName);
            mailtoLink  = [mailtoLink clamp:100000]; // will expand to twice the size and kern.argmax: 262144 causes NSTask with too long arguments to 'silently' fail with a posix spawn error 7
            NSDictionary *dict = @{@"title" : title, @"message" : message, @"mailto" : mailtoLink};
            NSData *dictjsondata = dict.JSONData;
            NSString *dictjsondatahexstring = dictjsondata.hexString;
            NSString *crashhelperpath = @[cc.resDir, @"CrashHelper.app/Contents/MacOS/CrashHelper"].path;
            NSTask *taskApp = [[NSTask alloc] init];


            
            @try
            {
                taskApp.launchPath = crashhelperpath;
                taskApp.arguments = @[dictjsondatahexstring];

                [taskApp launch];
                while (taskApp.isRunning)
                {
                    [NSThread sleepForTimeInterval:0.05];
                }
            }
            @catch (NSException *exception)
            {
                cc_log_error(@"could not spawn crash helper %@", exception.userInfo);

                if (alert(fatal ? @"Fatal Error".localized : @"Error".localized,
                          message,
                          @"Send to support".localized, fatal ? @"Quit".localized : @"Continue".localized, nil) == NSAlertFirstButtonReturn)
                {
                    [mailtoLink.escaped.URL open];
                }
            }
        }
        else
#endif
        {
            if (alert(fatal ? @"Fatal Error".localized : @"Error".localized,
                      message,
                      @"Send to support".localized, fatal ? @"Quit".localized : @"Continue".localized, nil) == NSAlertFirstButtonReturn)
            {
                [mailtoLink.escaped.URL open];
            }
        }

        if (fatal)
            exit(1);
    };


    dispatch_sync_main(block);
}

void alert_feedback_fatal(NSString *usermsg, NSString *details)
{
    alert_feedback(usermsg, details, YES);
    exit(1);
}

void alert_feedback_nonfatal(NSString *usermsg, NSString *details)
{
    alert_feedback(usermsg, details, NO);
}

NSInteger _alert_input(NSString *prompt, NSArray *buttons, NSString **result, BOOL useSecurePrompt)
{
    assert(buttons);
    assert(result);
    ASSERT_MAINTHREAD;

    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = prompt;
   
    cc_log_error(@"Alert Input: %@@", prompt.strippedOfNewlines);

    if (buttons.count > 0)
        [alert addButtonWithTitle:buttons[0]];
    if (buttons.count > 1)
        [alert addButtonWithTitle:buttons[1]];
    if (buttons.count > 2)
        [alert addButtonWithTitle:buttons[2]];
    
    NSTextField *input;
    if (useSecurePrompt)
        input = [[NSSecureTextField alloc] initWithFrame:NSMakeRect(0, 0, 310, 24)];
    else
        input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 310, 24)];

    alert.accessoryView = input;
    alert.window.initialFirstResponder = alert.accessoryView;
    
    NSInteger selectedButton = [alert runModal];

    cc_log_error(@"Alert Input: finished %li", (long)selectedButton);

    [input validateEditing];
    *result = input.stringValue;
    
    return selectedButton;
}

NSInteger alert_checkbox(NSString *title, NSString *prompt, NSArray <NSString *>*buttons, NSString *checkboxTitle, NSUInteger *checkboxStatus)
{
    assert(buttons);
    assert(checkboxStatus);
    ASSERT_MAINTHREAD;

    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = title;
    alert.informativeText = prompt;

    cc_log_error(@"Alert Checkbox: %@ - %@", title.strippedOfNewlines, prompt.strippedOfNewlines);

    if (buttons.count > 0)
        [alert addButtonWithTitle:buttons[0]];
    if (buttons.count > 1)
        [alert addButtonWithTitle:buttons[1]];
    if (buttons.count > 2)
        [alert addButtonWithTitle:buttons[2]];

    NSButton *input = [[NSButton alloc] initWithFrame:NSMakeRect(0, 0, 310, 24)];
    [input setButtonType:NSButtonTypeSwitch];
    input.state = (NSInteger )*checkboxStatus;
    input.title = checkboxTitle;

    alert.accessoryView = input;
    NSInteger selectedButton = [alert runModal];

    *checkboxStatus = (NSUInteger)input.state;

    cc_log_error(@"Alert Checkbox: finished %li %lu", (long)selectedButton, (unsigned long)*checkboxStatus);

    return selectedButton;
}

NSInteger alert_colorwell(NSString *prompt, NSArray <NSString *>*buttons, NSColor **selectedColor)
{
    assert(buttons);
    assert(selectedColor);
    ASSERT_MAINTHREAD;

    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = prompt;

    if (buttons.count > 0)
        [alert addButtonWithTitle:buttons[0]];
    if (buttons.count > 1)
        [alert addButtonWithTitle:buttons[1]];
    if (buttons.count > 2)
        [alert addButtonWithTitle:buttons[2]];

    NSColorWell *input = [[NSColorWell alloc] initWithFrame:NSMakeRect(0, 0, 310, 24)];
    input.color = *selectedColor;

    cc_log_error(@"Alert Colorwell: %@", prompt.strippedOfNewlines);

    
    alert.accessoryView = input;
    NSInteger selectedButton = [alert runModal];

    cc_log_error(@"Alert Colorwell: finished %li", selectedButton);

    *selectedColor = input.color;
    
    return selectedButton;
}

NSInteger alert_inputtext(NSString *prompt, NSArray *buttons, NSString **result)
{
    assert(buttons);
    assert(result);
    ASSERT_MAINTHREAD;

    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = prompt;
    
    cc_log_error(@"Alert Inputtext: %@", prompt.strippedOfNewlines);

    if (buttons.count > 0)
        [alert addButtonWithTitle:buttons[0]];
    if (buttons.count > 1)
        [alert addButtonWithTitle:buttons[1]];
    if (buttons.count > 2)
        [alert addButtonWithTitle:buttons[2]];

    NSScrollView *scrollview = [[NSScrollView alloc] initWithFrame:NSMakeRect(0, 0, 310, 200)];
    NSSize contentSize = [scrollview contentSize];
    
    [scrollview setBorderType:NSNoBorder];
    [scrollview setHasVerticalScroller:YES];
    [scrollview setHasHorizontalScroller:NO];
    [scrollview setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    
    NSTextView *theTextView = [[NSTextView alloc] initWithFrame:NSMakeRect(0, 0, contentSize.width, contentSize.height)];
    [theTextView setMinSize:NSMakeSize(0.0, contentSize.height)];
    [theTextView setMaxSize:NSMakeSize((CGFloat)FLT_MAX, (CGFloat)FLT_MAX)];
    [theTextView setVerticallyResizable:YES];
    [theTextView setHorizontallyResizable:NO];
    [theTextView setAutoresizingMask:NSViewWidthSizable];

    
    [[theTextView textContainer] setContainerSize:NSMakeSize(contentSize.width, (CGFloat)FLT_MAX)];
    [[theTextView textContainer] setWidthTracksTextView:YES];
    
    [scrollview setDocumentView:theTextView];

    
    NSString *inputString = *result;
    if (inputString.length)
        theTextView.string = inputString;
    
    alert.accessoryView = scrollview;
    NSInteger selectedButton = [alert runModal];
    *result = theTextView.string;

    cc_log_error(@"Alert Inputtext: finished %li %@", (long)selectedButton, *result);

    
    return selectedButton;
}

NSInteger alert_outputtext(NSString *message, NSArray *buttons, NSString *text)
{
    assert(buttons);
    ASSERT_MAINTHREAD;
    
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = message;
    
    if (buttons.count > 0)
        [alert addButtonWithTitle:buttons[0]];
    if (buttons.count > 1)
        [alert addButtonWithTitle:buttons[1]];
    if (buttons.count > 2)
        [alert addButtonWithTitle:buttons[2]];
    
    cc_log_error(@"Alert Outputtext: %@", message.strippedOfNewlines);

    NSScrollView *scrollview = [[NSScrollView alloc] initWithFrame:NSMakeRect(0, 0, 310, 200)];
    NSSize contentSize = [scrollview contentSize];
    
    [scrollview setBorderType:NSNoBorder];
    [scrollview setHasVerticalScroller:YES];
    [scrollview setHasHorizontalScroller:NO];
    [scrollview setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    
    NSTextView *theTextView = [[NSTextView alloc] initWithFrame:NSMakeRect(0, 0, contentSize.width, contentSize.height)];
    [theTextView setMinSize:NSMakeSize(0.0, contentSize.height)];
    [theTextView setMaxSize:NSMakeSize((CGFloat)FLT_MAX, (CGFloat)FLT_MAX)];
    [theTextView setVerticallyResizable:YES];
    [theTextView setHorizontallyResizable:NO];
    [theTextView setAutoresizingMask:NSViewWidthSizable];

    
    [[theTextView textContainer] setContainerSize:NSMakeSize(contentSize.width, (CGFloat)FLT_MAX)];
    [[theTextView textContainer] setWidthTracksTextView:YES];
    
    [scrollview setDocumentView:theTextView];

    
    theTextView.editable = NO;
    theTextView.string = text;
    
    alert.accessoryView = scrollview;
    NSInteger selectedButton = [alert runModal];
    
    cc_log_error(@"Alert Outputtext: finished %li", (long)selectedButton);

    return selectedButton;
}

NSInteger alert_selection_popup(NSString *prompt, NSArray<NSString *> *choices, NSArray<NSString *> *buttons, NSUInteger *result)
{
    assert(buttons);
    assert(choices);
    assert(result);
    ASSERT_MAINTHREAD;

    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = prompt;

    cc_log_error(@"Alert Selectionpopup: %@", prompt.strippedOfNewlines);

    if (buttons.count > 0)
        [alert addButtonWithTitle:buttons[0]];
    if (buttons.count > 1)
        [alert addButtonWithTitle:buttons[1]];
    if (buttons.count > 2)
        [alert addButtonWithTitle:buttons[2]];

    NSPopUpButton *input = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(0, 0, 310, 24)];
    for (NSString *str in choices)
        [input addItemWithTitle:str];

    alert.accessoryView = input;
    NSInteger selectedButton = [alert runModal];

    [input validateEditing];
    *result = (NSUInteger)input.indexOfSelectedItem;

    cc_log_error(@"Alert Selectionpopup: finished %li %lu", (long)selectedButton, (unsigned long)*result);

    
    return selectedButton;
}

NSInteger alert_selection_matrix(NSString *prompt, NSArray<NSString *> *choices, NSArray<NSString *> *buttons, NSUInteger *result)
{
    assert(buttons);
    assert(result);
    ASSERT_MAINTHREAD;

    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = prompt;
    
    cc_log_error(@"Alert Selectionmatrix: %@", prompt.strippedOfNewlines);

    if (buttons.count > 0)
        [alert addButtonWithTitle:buttons[0]];
    if (buttons.count > 1)
        [alert addButtonWithTitle:buttons[1]];
    if (buttons.count > 2)
        [alert addButtonWithTitle:buttons[2]];

    NSButtonCell *thepushbutton = [[NSButtonCell alloc] init];
    [thepushbutton setButtonType:NSButtonTypeRadio];

    NSMatrix *thepushbuttons = [[NSMatrix alloc] initWithFrame:NSMakeRect(0,0,269,17 * choices.count)
                                                          mode:NSRadioModeMatrix
                                                     prototype:thepushbutton
                                                  numberOfRows:(int)choices.count
                                               numberOfColumns:1];

    for (NSUInteger i = 0; i < choices.count; i++)
    {
        [thepushbuttons selectCellAtRow:(int)i column:0];

        NSString *title = choices[i];
        if (title.length > 150)
            title = makeString(@"%@ […] %@", [title substringToIndex:70], [title substringFromIndex:title.length-70]);

        [thepushbuttons.selectedCell setTitle:title];
    }
    [thepushbuttons selectCellAtRow:0 column:0];

    [thepushbuttons sizeToFit];

    alert.accessoryView = thepushbuttons;
    //[[alert window] makeFirstResponder:thepushbuttons];

    NSInteger selectedButton = [alert runModal];
//U    [[alert window] setInitialFirstResponder: thepushbuttons];

    *result = (NSUInteger)thepushbuttons.selectedRow;
    
    cc_log_error(@"Alert Selectionmatrix: finished %li %lu", (long)selectedButton, (unsigned long)*result);


    return selectedButton;
}

NSInteger alert_input(NSString *prompt, NSArray *buttons, NSString **result)
{
    return _alert_input(prompt, buttons, result, NO);
}

NSInteger alert_inputsecure(NSString *prompt, NSArray *buttons, NSString **result)
{
    return _alert_input(prompt, buttons, result, YES);
}

__attribute__((annotate("returns_localized_nsstring"))) static inline NSString *LocalizationNotNeeded(NSString *s) { return s; }
NSInteger alert(NSString *title, NSString *message, NSString *defaultButton, NSString *alternateButton, NSString *otherButton)
{
    return alert_customicon(title, message, defaultButton, alternateButton, otherButton, nil);
}

NSInteger alert_customicon(NSString *title, NSString *message, NSString *defaultButton, NSString *alternateButton, NSString *otherButton, NSImage *customIcon)
{
    ASSERT_MAINTHREAD;
    
    [NSApp activateIgnoringOtherApps:YES];
    
    cc_log_error(@"Alert: %@ - %@", title.strippedOfNewlines, message.strippedOfNewlines);
    
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = title;
    alert.informativeText = LocalizationNotNeeded(message);
    alert.icon = customIcon;
    
    if (defaultButton)
    {
        NSButton *b = [alert addButtonWithTitle:LocalizationNotNeeded(defaultButton)];
        if (defaultButton.associatedValue)
            [b setKeyEquivalent:defaultButton.associatedValue];
    }
    if (alternateButton)
    {
        NSButton *b = [alert addButtonWithTitle:alternateButton];
        if (alternateButton.associatedValue)
            [b setKeyEquivalent:alternateButton.associatedValue];
    }
    if (otherButton)
        [alert addButtonWithTitle:otherButton];
    
    NSInteger result = [alert runModal];
    
    cc_log_error(@"Alert: finished %li", (long)result);

    return result;
}

NSInteger alert_apptitled(NSString *message, NSString *defaultButton, NSString *alternateButton, NSString *otherButton)
{
    return alert(cc.appName, message, defaultButton, alternateButton, otherButton);
}

NSInteger _alert_dontwarnagain_prefs(NSString *identifier, NSString *title, NSString *message, NSString *defaultButton, NSString *alternateButton, NSString *dontwarnButton)
{
    ASSERT_MAINTHREAD;
    
    if (!identifier.defaultInt)
    {
        [NSApp activateIgnoringOtherApps:YES];
        
        cc_log_error(@"Alert: %@ - %@", title.strippedOfNewlines, message.strippedOfNewlines);
        
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = title;
        alert.informativeText = LocalizationNotNeeded(message);
        
        if (defaultButton)
        {
            NSButton *b = [alert addButtonWithTitle:LocalizationNotNeeded(defaultButton)];
            if (defaultButton.associatedValue)
                [b setKeyEquivalent:defaultButton.associatedValue];
        }
        if (alternateButton)
        {
            NSButton *b = [alert addButtonWithTitle:alternateButton];
            if (alternateButton.associatedValue)
                [b setKeyEquivalent:alternateButton.associatedValue];
        }

        alert.showsSuppressionButton = YES;
        alert.suppressionButton.title = dontwarnButton;
        
        NSInteger result = [alert runModal];
        
        cc_log_error(@"Alert: finished %li", (long)result);
        identifier.defaultInt = alert.suppressionButton.state;

        return result;
    }
    else
        return -1;
}

void alert_dontwarnagain_version(NSString *identifier, NSString *title, NSString *message, NSString *defaultButton, NSString *dontwarnButton)
{
    assert(defaultButton && dontwarnButton);

    dispatch_block_t block = ^
    {
        NSString *defaultKey = makeString(@"_%@_%@_asked", identifier, cc.appVersionString);
        if (!defaultKey.defaultInt)
        {
            NSAlert *alert = [[NSAlert alloc] init];
            
            alert.messageText = title;
            alert.informativeText = message;
            [alert addButtonWithTitle:defaultButton];
            alert.showsSuppressionButton = YES;
            alert.suppressionButton.title = dontwarnButton;
            
            cc_log_error(@"Alert Dontwarnagain: %@ - %@", title.strippedOfNewlines, message.strippedOfNewlines);

            [NSApp activateIgnoringOtherApps:YES];
            [alert runModal];
            
            cc_log_error(@"Alert Dontwarnagain: finished");

            defaultKey.defaultInt = alert.suppressionButton.state;
        }
    };

    if ([NSThread currentThread] == [NSThread mainThread])
        block();
    else
        dispatch_async_main(block);
}
void alert_dontwarnagain_ever(NSString *identifier, NSString *title, NSString *message, NSString *defaultButton, NSString *dontwarnButton)
{
    dispatch_block_t block = ^
    {
        NSString *defaultKey = makeString(@"_%@_asked", identifier);
        
        if (!defaultKey.defaultInt)
        {
            NSAlert *alert = [[NSAlert alloc] init];
            
            alert.messageText = title;
            alert.informativeText = message;
            [alert addButtonWithTitle:defaultButton];
            alert.showsSuppressionButton = YES;
            alert.suppressionButton.title = dontwarnButton;
            
            cc_log_error(@"Alert Dontwarnagainever: %@ - %@", title.strippedOfNewlines, message.strippedOfNewlines);

            [NSApp activateIgnoringOtherApps:YES];
            [alert runModal];
            
            cc_log_error(@"Alert Dontwarnagainever: finished");

            defaultKey.defaultInt = alert.suppressionButton.state;
        }
    };

    if ([NSThread currentThread] == [NSThread mainThread])
        block();
    else
        dispatch_async_main(block);
}


CGFloat _attributedStringHeightForWidth(NSAttributedString *string, CGFloat width)
{
    NSSize answer = NSZeroSize;
    if ([string length] > 0)
    {   // CREDITS: https://stackoverflow.com/questions/8945040/measure-string-height-in-cocoa
        // Checking for empty string is necessary since Layout Manager will give the nominal
        // height of one line if length is 0.  Our API specifies 0.0 for an empty string.
        NSSize size = NSMakeSize(width, (CGFloat)FLT_MAX);
        NSTextContainer *textContainer = [[NSTextContainer alloc] initWithContainerSize:size];
        NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:string];
        NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
        [layoutManager addTextContainer:textContainer];
        [textStorage addLayoutManager:layoutManager];
        //[layoutManager setHyphenationFactor:0.0]; // deprecated and not needed anyway
        
        // NSLayoutManager is lazy, so we need the following kludge to force layout:
        [layoutManager glyphRangeForTextContainer:textContainer];
        
        answer = [layoutManager usedRectForTextContainer:textContainer].size;
        
        // Adjust if there is extra height for the cursor
        NSSize extraLineSize = [layoutManager extraLineFragmentRect].size;
        if (extraLineSize.height > 0)
        {
            answer.height -= extraLineSize.height;
        }
    }
    
    return answer.height;
}


void alert_nonmodal(NSString *title, NSString *message, NSString *button)
{
    alert_nonmodal_customicon(title, message, button, nil);
}

void alert_nonmodal_customicon_block(NSString *title, NSString *message, NSString *button, NSImage *customIcon, BasicBlock block)
{
    ASSERT_MAINTHREAD;

    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:message attributes:@{NSFontAttributeName : [NSFont systemFontOfSize:11]}];
    CGFloat messageHeight = (CGFloat)MAX(30.0, _attributedStringHeightForWidth(attributedString, 300));
    CGFloat height = 100 + messageHeight;
    CLFakeAlertWindow *fakeAlertWindow = [[CLFakeAlertWindow alloc] initWithContentRect:NSMakeRect(0.0, 0.0, 420.0, height)
                                                            styleMask:NSWindowStyleMaskTitled
                                                              backing:NSBackingStoreBuffered
                                                                defer:NO];
    
    
    NSTextField *alertTitle = [[NSTextField alloc] initWithFrame:NSMakeRect(100.0, height-30, 300.0, 17.0)];
    NSTextView *alertMessage = [[NSTextView alloc] initWithFrame:NSMakeRect(100.0-3, 50, 300.0, height-50-40)];
    NSImageView *alertImage = [[NSImageView alloc] initWithFrame:NSMakeRect(20.0, height-80, 64, 64)];
    NSButton *firstButton = [[NSButton alloc] initWithFrame:NSMakeRect(315.0, 12, 90, 30)];
    
    
    alertTitle.stringValue = title;
    alertMessage.string = message;
    
    cc_log_error(@"Alert: nonmodal  %@ - %@", title.strippedOfNewlines, message.strippedOfNewlines);

    alertTitle.font = [NSFont boldSystemFontOfSize:14];
    alertTitle.alignment = NSTextAlignmentLeft;
    alertTitle.bezeled = NO;
    [alertTitle setDrawsBackground:NO];
    [alertTitle setLineBreakMode:NSLineBreakByWordWrapping];
    [alertTitle setEditable:NO];
    [alertTitle setSelectable:NO];
    [fakeAlertWindow.contentView addSubview:alertTitle];
    
    alertMessage.font = [NSFont systemFontOfSize:11];
    alertMessage.alignment = NSTextAlignmentLeft;
    [alertMessage setDrawsBackground:NO];
    [alertMessage setEditable:NO];
    [alertMessage setSelectable:NO];
    [fakeAlertWindow.contentView addSubview:alertMessage];
    
    
    alertImage.image = OBJECT_OR(customIcon, @"AppIcon".namedImage);
    [fakeAlertWindow.contentView addSubview:alertImage];
    
    firstButton.bezelStyle = NSBezelStyleRounded;
    firstButton.title = button;
    firstButton.keyEquivalent = @"\r";
    [fakeAlertWindow.contentView addSubview:firstButton];
    
    __weak  CLFakeAlertWindow *weakWindow = fakeAlertWindow;
    firstButton.actionBlock = ^(id sender)
    {
        [weakWindow close];
        if (block)
            block();
    };
    
    fakeAlertWindow.releasedWhenClosed = NO;
    [fakeAlertWindow center];
    
    [NSApp activateIgnoringOtherApps:YES];
    [fakeAlertWindow makeKeyAndOrderFront:@""];
}

void alert_nonmodal_customicon(NSString *title, NSString *message, NSString *button, NSImage *customIcon)
{
    alert_nonmodal_customicon_block(title, message, button, customIcon, nil);
}

void alert_nonmodal_checkbox(NSString *title, NSString *message, NSString *button, NSString *checkboxTitle, NSInteger checkboxStatusIn, IntInBlock resultBlock)
{
    ASSERT_MAINTHREAD;

    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:message attributes:@{NSFontAttributeName : [NSFont systemFontOfSize:11]}];
    CGFloat messageHeight = (CGFloat)MAX(50.0, _attributedStringHeightForWidth(attributedString, 300));
    CGFloat height = 120 + messageHeight;
    CLFakeAlertWindow *fakeAlertWindow = [[CLFakeAlertWindow alloc] initWithContentRect:NSMakeRect(0.0, 0.0, 420.0, height)
                                                            styleMask:NSWindowStyleMaskTitled
                                                              backing:NSBackingStoreBuffered
                                                                defer:NO];
    
    
    NSTextField *alertTitle = [[NSTextField alloc] initWithFrame:NSMakeRect(100.0, height-30, 300.0, 17.0)];
    NSTextView *alertMessage = [[NSTextView alloc] initWithFrame:NSMakeRect(100.0-3, 70, 300.0, height-70-40)];
    NSImageView *alertImage = [[NSImageView alloc] initWithFrame:NSMakeRect(20.0, height-80, 64, 64)];
    NSButton *firstButton = [[NSButton alloc] initWithFrame:NSMakeRect(315.0, 12, 90, 30)];
    
    
    alertTitle.stringValue = title;
    alertMessage.string = message;
  
    cc_log_error(@"Alert: nonmodal checkbox %@ - %@", title.strippedOfNewlines, message.strippedOfNewlines);

    
    alertTitle.font = [NSFont boldSystemFontOfSize:14];
    alertTitle.alignment = NSTextAlignmentLeft;
    alertTitle.bezeled = NO;
    [alertTitle setDrawsBackground:NO];
    [alertTitle setLineBreakMode:NSLineBreakByWordWrapping];
    [alertTitle setEditable:NO];
    [alertTitle setSelectable:NO];
    [fakeAlertWindow.contentView addSubview:alertTitle];
    
    alertMessage.font = [NSFont systemFontOfSize:11];
    alertMessage.alignment = NSTextAlignmentLeft;
    [alertMessage setDrawsBackground:NO];
    [alertMessage setEditable:NO];
    [alertMessage setSelectable:NO];
    [fakeAlertWindow.contentView addSubview:alertMessage];
    
    
    alertImage.image = @"AppIcon".namedImage;
    [fakeAlertWindow.contentView addSubview:alertImage];
    
    firstButton.bezelStyle = NSBezelStyleRounded;
    firstButton.title = button;
    firstButton.keyEquivalent = @"\r";
    [fakeAlertWindow.contentView addSubview:firstButton];
    
    
    NSButton *input = [[NSButton alloc] initWithFrame:NSMakeRect(105, 55, 310, 24)];
    [input setButtonType:NSButtonTypeSwitch];
    input.state = checkboxStatusIn;
    input.title = checkboxTitle;
    [fakeAlertWindow.contentView addSubview:input];


    
    __weak  CLFakeAlertWindow *weakWindow = fakeAlertWindow;
    __weak  NSButton *weakCheckbox = input;
    firstButton.actionBlock = ^(id sender)
    {
        resultBlock((int)weakCheckbox.state);
        [weakWindow close];
    };
    
    fakeAlertWindow.releasedWhenClosed = NO;
    [fakeAlertWindow center];
    
    [NSApp activateIgnoringOtherApps:YES];
    [fakeAlertWindow makeKeyAndOrderFront:@""];
}

void alert_nonmodal_dontwarnagain_ever(NSString *identifier, NSString *title, NSString *message, NSString *defaultButton, NSString *dontwarnButton)
{
    dispatch_block_t block = ^
    {
        NSString *defaultKey = makeString(@"_%@_asked", identifier);
        
        if (!defaultKey.defaultInt)
        {
            cc_log_error(@"Alert Dontwarnagainever: %@ - %@", title.strippedOfNewlines, message.strippedOfNewlines);

            alert_nonmodal_checkbox(title, [message stringByAppendingString:@"\n\n"], defaultButton, dontwarnButton, 0, ^(int checkboxResult)
            {
                 cc_log_error(@"Alert Dontwarnagainever: finished: %i", checkboxResult);
                 if (checkboxResult)
                     defaultKey.defaultInt = checkboxResult;
            });
        }
    };

    if ([NSThread currentThread] == [NSThread mainThread])
        block();
    else
        dispatch_async_main(block);
}

#endif
