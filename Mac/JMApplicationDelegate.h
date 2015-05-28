//
//  JMApplicationDelegate.h
//  CoreLib
//
//  Created by CoreCode on 05.05.15.
/*	Copyright (c) 2015 CoreCode
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "CoreLib.h"


@interface JMApplicationDelegate : NSObject 


- (IBAction)openWindow:(__strong NSWindow **)window nibName:(NSString *)nibName;
- (IBAction)openURL:(id)sender;
@property (readonly, nonatomic) BOOL isRateable;


- (void)welcomeOrExpireDemo:(int)demoLimit welcomeText:(NSString *)welcomeText expiryText:(NSString *)expiryText;
- (void)increaseUsages:(int)allowReviewLimit requestReview:(int)requestReviewLimit feedbackText:(NSString *)feedbackText;
- (void)checkBetaExpiryForDate:(const char *)preprocessorDateString days:(uint8_t)expiryDays;
- (void)checkMASReceipt;
- (void)checkAndReportCrashesContaining:(NSStringArray *)neccessarySubstringsOrNil to:(NSString *)destinationMail;
- (void)checkAppMovements;

#ifdef USE_SPARKLE
- (IBAction)initUpdateCheck;
- (IBAction)setUpdateCheck:(id)sender;
#endif


@end