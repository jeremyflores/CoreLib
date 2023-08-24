//
//  CoreLib.h
//  CoreLib
//
//  Created by CoreCode on 12.04.12.
/*	Copyright © 2022 CoreCode Limited
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#ifdef __OBJC__


#ifndef CORELIB
#define CORELIB 1


#ifdef __cplusplus
extern "C"
{
#endif


// include system headers and make sure requrements are met
#if __has_feature(modules)
@import Darwin.TargetConditionals;
@import Darwin.Availability;
#else
#import <TargetConditionals.h>
#import <Availability.h>
#endif

#if ! __has_feature(objc_arc) // this is hit even when including corelib in the PCH and any file in the project - maybe not even using corelib - still uses manual retain count, so its a warning and not an error
    #warning CoreLib > 1.13 does not support manual reference counting anymore
#endif

#import "CLAlert.h"
#import "CLAssert.h"
#import "CLConfiguration.h"
#import "CLConstantKey.h"
#import "CLConvenience.h"
#import "CLCoreLib.h"
#import "CLCustomSupportRequestProvider.h"
#import "CLDispatch.h"
#import "CLEnvironment.h"
#import "CLFakeAlertWindow.h"
#import "CLGlobals.h"
#import "CLLogic.h"
#import "CLLogging.h"
#import "CLMakers.h"
#import "CLMath.h"
#import "CLOpenChoice.h"
#import "CLPurchaseActivationType.h"
#import "CLRandom.h"
#import "CLRunShCommand.h"
#import "CLSecurityImport.h"
#import "CLSwifty.h"
#import "CLTarget.h"
#import "CLTypes.h"
#import "CLUIImport.h"
#import "CLUserDefaults.h"



// !!!: UNDEFS
// this makes sure youo not compare the return values of our alert*() functions against old values and use NSLog when you should use ASL. remove as appropriate
#ifndef IMADESURENOTTOCOMPAREALERTRETURNVALUESAGAINSTOLDRETURNVALUES
    // alert() and related corelib functions previously returned old deprecated return values from NSRunAlertPanel() and friends. now they return new NSAlertFirst/..ButtonReturn values. we undefine the old return values to make sure you don't use them. if you use NSRunAlertPanel() and friends directly in your code you can set the define to prevent the errors after making sure to update return value checks of alert*()
    #define NSAlertDefaultReturn
    #define NSAlertAlternateReturn
    #define NSAlertOtherReturn
    #define NSAlertErrorReturn
    #define NSOKButton
    #define NSCancelButton
#endif
#ifndef DISABLELOGGINGIMPLEMENTATION
    #define asl_log
    #define asl_NSLog_debug
    #define NSLog
    #define os_log
    #define os_log_info
    #define os_log_debug
    #define os_log_error
    #define os_log_fault
#endif

#ifdef __cplusplus
}
#endif

#endif
#endif


// !!!: INCLUDES
#import "AppKit+CoreCode.h"
#import "Foundation+CoreCode.h"
