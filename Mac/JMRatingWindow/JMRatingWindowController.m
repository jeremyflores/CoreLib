//
//  JMRatingWindowController.m
//  CoreLib
//
//  Created by CoreCode on 18/04/2017.
/*	Copyright © 2017 CoreCode Limited
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "JMRatingWindowController.h"

@interface JMRatingWindowController ()

@property (weak, nonatomic) IBOutlet NSView *initialView;
@property (weak, nonatomic) IBOutlet NSView *happyView;
@property (weak, nonatomic) IBOutlet NSView *angryView;
@property (weak, nonatomic) IBOutlet NSTextField *feedbackTextField;

@end


@implementation JMRatingWindowController


- (instancetype)init
{
    return [super initWithWindowNibName: @"JMRatingWindow"];
}


- (void)windowDidLoad
{
    [super windowDidLoad];
    
    self.initialView.hidden = NO;
    self.angryView.hidden = YES;
    self.happyView.hidden = YES;

}

- (IBAction)happyClicked:(id)sender
{
    self.initialView.hidden = YES;
    self.angryView.hidden = YES;
    self.happyView.hidden = NO;
}

- (IBAction)notsureClicked:(id)sender
{
    [self.window close];
}

- (IBAction)problemsClicked:(id)sender
{
    self.initialView.hidden = YES;
    self.angryView.hidden = NO;
    self.happyView.hidden = YES;
}

- (IBAction)notnowClicked:(id)sender
{
    [self.window close];
}

- (IBAction)closeClicked:(id)sender
{
    [self.window close];
}

- (IBAction)dontshowClicked:(id)sender
{
    [self.window close];

    
    NSInteger res = alert(@"Confirmation", makeString(@"%@ asks for your feedback only rarely and at maximum only once per app-version. Are you sure you want to turn this off completely?", cc.appName),
                          @"Cancel", @"Turn off feedback dialoge", nil);
    
    if (res == NSAlertSecondButtonReturn)
        @"corelib_dontaskagain".defaultInt = 1;
}

- (IBAction)ratemacupdateClicked:(id)sender
{
    [cc openURL:openMacupdateWebsite];
    [self.window close];
}

- (IBAction)rateappstoreClicked:(id)sender
{
    [cc openURL:openAppStoreApp];
    [self.window close];
}

- (IBAction)sendfeedbackClicked:(id)sender
{
    [cc sendSupportRequestMail:self.feedbackTextField.stringValue];
    [self.window close];
}

- (void) windowWillClose:(NSNotification *)notification
{
    if (_closeBlock)
        _closeBlock();
}

@end