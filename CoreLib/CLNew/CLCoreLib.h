//
//  CLCoreLib.h
//  MacUpdater
//
//  Created by Carterhaugh LLC on 8/15/23.
//  Copyright © 2023 CoreCode Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CLCustomSupportRequestProvider.h"
#import "CLOpenChoice.h"
#import "CLTarget.h"



@interface CLCoreLib : NSObject

@property(readonly, weak, nonatomic) id<CLCustomSupportRequestProvider> customSupportRequestProvider;
// info bundle key convenience
@property (readonly, nonatomic) NSString *appBundleIdentifier;
@property (readonly, nonatomic) int appBuildNumber;
@property (readonly, nonatomic) NSString *appVersionString;
@property (readonly, nonatomic) NSString *appName;
// path convenience
@property (readonly, nonatomic) NSString *prefsPath;
@property (readonly, nonatomic) NSString *resDir;
@property (readonly, nonatomic) NSString *docDir;
@property (readonly, nonatomic) NSString *deskDir;
@property (readonly, nonatomic) NSString *suppDir;
@property (readonly, nonatomic) NSURL *prefsURL;
@property (readonly, nonatomic) NSURL *resURL;
@property (readonly, nonatomic) NSURL *docURL;
@property (readonly, nonatomic) NSURL *deskURL;
@property (readonly, nonatomic) NSURL *suppURL;
@property (readonly, nonatomic) NSURL *homeURLInsideSandbox;
@property (readonly, nonatomic) NSURL *homeURLOutsideSandbox;
// misc
@property (readonly, nonatomic) NSArray <NSString *>*appCrashLogFilenames;
@property (readonly, nonatomic) NSArray <NSString *>*appCrashLogs;
@property (readonly, nonatomic) NSString *appChecksumSHA;
@property (readonly, nonatomic) NSString *appChecksumIncludingFrameworksSHA;

// convenience method that calls -initWithCustomSupportRequestProvider:andBundlerIdentifier: with a nil bundleIdentifier
-(instancetype)initWithCustomSupportRequestProvider:(id<CLCustomSupportRequestProvider>)customSupportRequestProvider;

-(instancetype)initWithCustomSupportRequestProvider:(id<CLCustomSupportRequestProvider>)customSupportRequestProvider
                                       andSuiteName:(NSString *)suiteName NS_DESIGNATED_INITIALIZER; // suite name -> bundle identifier if no app suite is set up
-(instancetype)init NS_UNAVAILABLE;

- (void)openURL:(CLOpenChoice)choice;
#if CL_TARGET_CLI || CL_TARGET_OSX
- (void)sendSupportRequestMail:(NSString *)text;
#endif
@end

