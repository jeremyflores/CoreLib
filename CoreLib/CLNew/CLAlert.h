//
//  CLAlert.h
//  MacUpdater
//
//  Created by Carterhaugh LLC on 8/15/23.
//  Copyright © 2023 CoreCode Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CLTarget.h"
#import "CLTypes.h"
#import "CLUIImport.h"

#if CL_TARGET_IOS || CL_TARGET_OSX
NSInteger alert_selection_popup(NSString *prompt, NSArray<NSString *> *choices, NSArray<NSString *> *buttons, NSUInteger *result);    // alert with popup button for selection of choice
NSInteger alert_selection_matrix(NSString *prompt, NSArray<NSString *> *choices, NSArray<NSString *> *buttons, NSUInteger *result);  // alert with radiobutton matrix for selection of choice
NSInteger alert_input(NSString *title, NSArray *buttons, NSString **result); // alert with text field prompting users
NSInteger alert_inputtext(NSString *title, NSArray *buttons, NSString **result); // alert with large text view prompting users
NSInteger alert_checkbox(NSString *title, NSString *message, NSArray <NSString *>*buttons, NSString *checkboxTitle, NSUInteger *checkboxStatus); // alert with a single checkbox

#if CL_TARGET_OSX
NSInteger alert_colorwell(NSString *prompt, NSArray <NSString *>*buttons, NSColor **selectedColor); // alert with a colorwell for choosing colors
NSInteger alert_customicon(NSString *title, NSString *message, NSString *defaultButton, NSString *alternateButton, NSString *otherButton, NSImage *customIcon);
#endif

NSInteger alert_inputsecure(NSString *prompt, NSArray *buttons, NSString **result);
NSInteger alert_outputtext(NSString *message, NSArray *buttons, NSString *text);
NSInteger alert_apptitled(NSString *message, NSString *defaultButton, NSString *alternateButton, NSString *otherButton);
NSInteger alert(NSString *title, NSString *message, NSString *defaultButton, NSString *alternateButton, NSString *otherButton);
void alert_dontwarnagain_version(NSString *identifier, NSString *title, NSString *message, NSString *defaultButton, NSString *dontwarnButton)  __attribute__((nonnull (4, 5)));
void alert_dontwarnagain_ever(NSString *identifier, NSString *title, NSString *message, NSString *defaultButton, NSString *dontwarnButton) __attribute__((nonnull (4, 5)));
NSInteger _alert_dontwarnagain_prefs(NSString *identifier, NSString *title, NSString *message, NSString *defaultButton, NSString *alternateButton, NSString *dontwarnButton);
void alert_feedback_fatal(NSString *usermsg, NSString *details) __attribute__((noreturn));
void alert_feedback_nonfatal(NSString *usermsg, NSString *details);

#if CL_TARGET_OSX
void alert_nonmodal(NSString *title, NSString *message, NSString *button);
void alert_nonmodal_customicon(NSString *title, NSString *message, NSString *button, NSImage *customIcon);
void alert_nonmodal_customicon_block(NSString *title, NSString *message, NSString *button, NSImage *customIcon, BasicBlock block);
void alert_nonmodal_checkbox(NSString *title, NSString *message, NSString *button, NSString *checkboxTitle, NSInteger checkboxStatusIn, IntInBlock resultBlock);
void alert_nonmodal_dontwarnagain_ever(NSString *identifier, NSString *title, NSString *message, NSString *defaultButton, NSString *dontwarnButton);
#endif

#endif
