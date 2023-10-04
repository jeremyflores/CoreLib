//
//  CLCoreLib.m
//  MacUpdater
//
//  Created by Carterhaugh LLC on 8/15/23.
//  Copyright © 2023 CoreCode Limited. All rights reserved.
//

#import "CLCoreLib.h"

#import "CLGlobals.h"
#import "CLUIImport.h"

#import "Foundation+CoreCode.h"

#if __has_feature(modules)
@import Darwin.POSIX.unistd;
@import Darwin.POSIX.sys.types;
@import Darwin.POSIX.pwd;
@import Darwin.POSIX.sys.types;
@import Darwin.sys.sysctl;
#include <assert.h>
#else
#include <unistd.h>
#include <sys/types.h>
#include <pwd.h>
#include <assert.h>
#include <sys/types.h>
#include <sys/sysctl.h>
#endif

@interface CLCoreLib ()

@property(weak, nonatomic) id<CLCustomSupportRequestProvider> customSupportRequestProvider;

@end


@implementation CLCoreLib

@dynamic appCrashLogs, appCrashLogFilenames, appBundleIdentifier, appBuildNumber, appVersionString, appName, resDir, docDir, suppDir, resURL, docURL, suppURL, deskDir, deskURL, prefsPath, prefsURL, homeURLInsideSandbox, homeURLOutsideSandbox;

#ifdef USE_SECURITY
@dynamic appChecksumSHA, appChecksumIncludingFrameworksSHA;
#endif

#if CL_TARGET_OSX
NSString *_machineType(void);
BOOL _isUserAdmin(void);
__attribute__((noreturn)) void exceptionHandler(NSException *exception)
{
    NSString *exceptionDetails = makeString(@" %@ %@ %@ %@", exception.description, exception.reason, exception.userInfo.description, exception.callStackSymbols);
    NSString *exceptionInfoToStore = [NSString stringWithFormat:@"Date: %@ Exception:%@", NSDate.date.shortDateAndTimeString, exceptionDetails];
    
    cc_defaults_addtoarray(kExceptionInformationKey, exceptionInfoToStore, 10);
    
    alert_feedback_fatal(exception.name, exceptionDetails);
}
#endif

-(instancetype)initWithCustomSupportRequestProvider:(id<CLCustomSupportRequestProvider>)customSupportRequestProvider {
    CLCoreLib *coreLib = [self initWithCustomSupportRequestProvider:customSupportRequestProvider andSuiteName:nil];
    return coreLib;
}

-(instancetype)initWithCustomSupportRequestProvider:(id<CLCustomSupportRequestProvider>)customSupportRequestProvider
                                       andSuiteName:(NSString *)suiteName {
    assert(!cc);

    if ((self=[super init])) {
        self.customSupportRequestProvider = customSupportRequestProvider;

        NSUserDefaults *_userDefaults;
        if (!suiteName || suiteName.length == 0) {
            _userDefaults = NSUserDefaults.standardUserDefaults;
        }
        else {
            _userDefaults = [[NSUserDefaults alloc] initWithSuiteName:suiteName];
        }

        initializeCLGlobals(self, _userDefaults);

#ifndef SKIP_CREATE_APPSUPPORT_DIRECTORY
        if (self.appName)
        {
            BOOL exists = self.suppURL.fileExists;
            
#if CL_TARGET_OSX
            if ((!exists && self.suppURL.fileIsSymlink) ||  // broken symlink
                (exists && !self.suppURL.fileIsDirectory))  // not a folder
            {
                alert_apptitled(makeString(@"This application can not be launched because its 'Application Support' folder is not a folder but a file. Please remove the file '%@' and re-launch this app.", self.suppURL.path), @"OK", nil, nil);
            }
            else
#endif
                if (!exists) // non-existant
            {
                NSError *error;
                BOOL succ = [fileManager createDirectoryAtURL:self.suppURL withIntermediateDirectories:YES attributes:nil error:&error];
                if (!succ)
                {
#if CL_TARGET_OSX
                    alert_apptitled(makeString(@"This application can not be launched because the 'Application Support' can not be created at the path '%@'.\nError: %@", self.suppURL.path, error.localizedDescription), @"OK", nil, nil);
#else
                    cc_log(@"This application can not be launched because the 'Application Support' can not be created at the path '%@'.\nError: %@", self.suppURL.path, error.localizedDescription);

#endif
                    exit(1);
                }
            }
        }
#endif

    #ifdef DEBUG
        #ifndef XCTEST
            BOOL isSandbox = [@"~/Library/".expanded contains:@"/Library/Containers/"];

            #ifdef SANDBOX
                assert(isSandbox);
            #else
                assert(!isSandbox);
            #endif
        #endif

        #ifdef NDEBUG
            cc_log(@"Warning: you are running in DEBUG mode but have disabled assertions (NDEBUG)");
        #endif

        #if !defined(XCTEST) || !XCTEST
            NSString *bundleID = [bundle objectForInfoDictionaryKey:@"CFBundleIdentifier"];
            if (![[self appBundleIdentifier] isEqualToString:bundleID] && self.appName)
            {
                cc_log_error(@"Error: bundle identifier doesn't match");

                exit(666);
            }
        #endif

        if ([(NSNumber *)[bundle objectForInfoDictionaryKey:@"LSUIElement"] boolValue] &&
            ![(NSString *)[bundle objectForInfoDictionaryKey:@"NSPrincipalClass"] isEqualToString:@"JMDocklessApplication"])
            cc_log_debug(@"Warning: app can hide dock symbol but has no fixed principal class");

#ifndef CLI
        if (![[(NSString *)[bundle objectForInfoDictionaryKey:@"MacupdaternetProductPage"] lowercaseString] contains:self.appName.lowercaseString] && ((NSString *)[NSBundle.mainBundle objectForInfoDictionaryKey:@"FilehorseProductPage"]).length)
            cc_log_debug(@"Info: info.plist key MacupdaternetProductPage not properly set - will fall back to FileHorse");
        else if (![[(NSString *)[bundle objectForInfoDictionaryKey:@"MacupdaternetProductPage"] lowercaseString] contains:self.appName.lowercaseString])
            cc_log_debug(@"Warning: info.plist key MacupdaternetProductPage not properly set");

        if (![[(NSString *)[bundle objectForInfoDictionaryKey:@"StoreProductPage"] lowercaseString] contains:self.appName.lowercaseString] && ((NSString *)[NSBundle.mainBundle objectForInfoDictionaryKey:@"AlternativetoProductPage"]).length)
            cc_log_debug(@"Info: info.plist key StoreProductPage not properly set - will fall back to AlternativeTo");
        else if (![[(NSString *)[bundle objectForInfoDictionaryKey:@"StoreProductPage"] lowercaseString] contains:self.appName.lowercaseString])
            cc_log_debug(@"Warning: info.plist key StoreProductPage not properly set (%@ NOT CONTAINS %@)", [(NSString *)[bundle objectForInfoDictionaryKey:@"StoreProductPage"] lowercaseString], self.appName.lowercaseString);

        
        if (!((NSString *)[bundle objectForInfoDictionaryKey:@"LSApplicationCategoryType"]).length)
            cc_log(@"Warning: LSApplicationCategoryType not properly set");
#endif
        
        
        
        if (NSClassFromString(@"JMRatingWindowController") &&
            NSProcessInfo.processInfo.environment[@"XCInjectBundleInto"] != nil)
        {
#if CL_TARGET_OSX
            assert(@"icon-appstore".namedImage);
            assert(@"icon-macupdater".namedImage);
            assert(@"icon-filehorse".namedImage);
            assert(@"icon-alternativeto".namedImage);
            assert(@"JMRatingWindow.nib".resourceURL);
#endif
        }
        #ifdef USE_SPARKLE
            assert(@"dsa_pub.pem".resourceURL);
        #endif
    #else
        #if !defined(NDEBUG) && !defined(CLI)
            cc_log_error(@"Warning: you are not running in DEBUG mode but have not disabled assertions (NDEBUG)");
        #endif
    #endif

        
    #if CL_TARGET_OSX
    #ifndef DONT_CRASH_ON_EXCEPTIONS
        NSSetUncaughtExceptionHandler(&exceptionHandler);
    #endif

#ifndef CLI
        #if !defined(XCTEST) || !XCTEST

        NSString *frameworkPath = bundle.privateFrameworksPath;
        for (NSString *framework in frameworkPath.directoryContents)
        {
            NSString *smylinkToBinaryPath = makeString(@"%@/%@/%@", frameworkPath, framework, framework.stringByDeletingPathExtension);

            if (!smylinkToBinaryPath.fileIsAlias)
            {
#ifdef DEBUG
                if ([framework hasPrefix:@"libclang"]) continue;
#endif
                alert_apptitled(makeString(@"This application is damaged. Either your download was damaged or you used a faulty program to extract the ZIP archive. Please re-download and make sure to use the ZIP decompression built into Mac OS X.\n\nOffending Path: %@", smylinkToBinaryPath), @"OK", nil, nil);
                exit(1);
            }
#ifdef DEBUG
            NSString *versionsPath = makeString(@"%@/%@/Versions", frameworkPath, framework);
            for (NSString *versionsEntry in versionsPath.directoryContents)
            {
                if ((![versionsEntry isEqualToString:@"A"]) && (![versionsEntry isEqualToString:@"B"]) && (![versionsEntry isEqualToString:@"Current"]))
                {
                    cc_log_error(@"The frameworks are damaged probably by lowercasing. Either your download was damaged or you used a faulty program to extract the ZIP archive. Please re-download and make sure to use the ZIP decompression built into Mac OS X.");
                    exit(1);
                }
            }
            NSString *versionAPath = makeString(@"%@/%@/Versions/A", frameworkPath, framework);
            NSString *versionBPath = makeString(@"%@/%@/Versions/B", frameworkPath, framework);
            NSString *versionPath = versionAPath.fileExists ? versionAPath : versionBPath;
            for (NSString *entry in versionPath.directoryContents)
            {
                if (([entry isEqualToString:@"headers"]) && (![entry isEqualToString:@"resources"]))
                {
                    cc_log_error(@"The frameworks are damaged probably by lowercasing. Either your download was damaged or you used a faulty program to extract the ZIP archive. Please re-download and make sure to use the ZIP decompression built into Mac OS X.");
                    exit(1);
                }
            }
#endif
        }
    #endif
#endif
#endif
        
        RANDOM_INIT
    }

    assert(cc);

    return self;
}


- (NSString *)prefsPath
{
    return makeString(@"~/Library/Preferences/%@.plist", self.appBundleIdentifier).expanded;
}

- (NSURL *)prefsURL
{
    return self.prefsPath.fileURL;
}

- (NSArray *)appCrashLogFilenames // doesn't do anything in sandbox!
{
    NSArray <NSString *> *logs1 = @"~/Library/Logs/DiagnosticReports/".expanded.directoryContents;
    logs1 = [logs1 filteredUsingPredicateString:@"self BEGINSWITH[cd] %@ AND (self ENDSWITH '.crash' OR self ENDSWITH '.ips')", self.appName]; // there is also .spin and .diag but we aren't interested in them ATM
    logs1 = [logs1 mapped:^id(NSString *input) { return [@"~/Library/Logs/DiagnosticReports/".stringByExpandingTildeInPath stringByAppendingPathComponent:input]; }];
    NSArray <NSString *> *logs2 = @"/Library/Logs/DiagnosticReports/".expanded.directoryContents;
    logs2 = [logs2 filteredUsingPredicateString:@"self BEGINSWITH[cd] %@ AND (self ENDSWITH '.crash' OR self ENDSWITH '.ips')", self.appName];
    logs2 = [logs2 mapped:^id(NSString *input) { return [@"/Library/Logs/DiagnosticReports/" stringByAppendingPathComponent:input]; }];

    
    NSArray <NSString *> *logs = [logs1 arrayByAddingObjectsFromArray:logs2];
    return logs;
}

- (NSArray *)appCrashLogs // doesn't do anything in sandbox!
{
    NSArray <NSString *> *logFilenames = self.appCrashLogFilenames;
    NSArray <NSString *> *logs = [logFilenames mapped:^id(NSString *input) { return [input.contents.string split:@"/System/Library/"][0]; }];

    return logs;
}

- (NSString *)appBundleIdentifier
{
    return NSBundle.mainBundle.bundleIdentifier;
}

- (NSString *)appVersionString
{
    return [NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

- (NSString *)appName
{
#if defined(XCTEST) && XCTEST
    return @"TEST";
#else
    return [NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleName"];
#endif
}

- (int)appBuildNumber
{
#ifdef CLI
#ifndef CLI_BUNDLEVERSION
#define CLI_BUNDLEVERSION 1
#endif
    return @(CLI_BUNDLEVERSION).intValue;
#else
    NSString *bundleVersion = [NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleVersion"];
    return bundleVersion.intValue;
#endif
}

- (NSString *)resDir
{
    return NSBundle.mainBundle.resourcePath;
}

- (NSURL *)resURL
{
    return NSBundle.mainBundle.resourceURL;
}

- (NSString *)docDir
{
    return NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
}

- (NSString *)deskDir
{
    return NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES)[0];
}

- (NSURL *)homeURLInsideSandbox
{
    return NSHomeDirectory().fileURL;
}

- (NSURL *)homeURLOutsideSandbox
{
    struct passwd *pw = getpwuid(getuid());
    assert(pw);
    NSString *realHomePath = @(pw->pw_dir);
    NSURL *realHomeURL = [NSURL fileURLWithPath:realHomePath];

    return realHomeURL;
}


- (NSURL *)docURL
{
    return [NSFileManager.defaultManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask][0];
}

- (NSURL *)deskURL
{
    return [NSFileManager.defaultManager URLsForDirectory:NSDesktopDirectory inDomains:NSUserDomainMask][0];
}

- (NSString *)suppDir
{
    return [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:self.appName];
}

- (NSURL * __nonnull)suppURL
{
    NSURL *dir = [NSFileManager.defaultManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask][0];

    NSString *appName = self.appName;
    
    if (!appName)
        appName =  [NSProcessInfo.processInfo.arguments.firstObject split:@"/"].lastObject;
    
    return [dir add:appName];
}

- (NSString *)appChecksumSHA
{
    NSURL *u = NSBundle.mainBundle.executableURL;
    
    return u.fileChecksumSHA;
}

- (NSString *)appChecksumIncludingFrameworksSHA
{
    NSURL *u = NSBundle.mainBundle.executableURL;
    
    NSString *checksum = [u.fileChecksumSHA clamp:10];
    
    for (NSURL *framework in NSBundle.mainBundle.privateFrameworksURL.directoryContents)
    {
        NSURL *exe = [NSBundle bundleWithURL:framework].executableURL;
        
        NSString *frameworkChecksum = exe.fileChecksumSHA;
        
        checksum = makeString(@"%@ %@", checksum, [frameworkChecksum clamp:10]);
    }
    
    return checksum;
}

#if CL_TARGET_CLI || CL_TARGET_OSX
- (void)sendSupportRequestMail:(NSString *)text
{
    NSString *urlString = @"";

    NSString *encodedPrefs = @"";
    NSString *crashReports = @"";

    BOOL shouldIncludeCustomerSupportRequestPreferences = NO;

#if CL_TARGET_CLI
    shouldIncludeCustomerSupportRequestPreferences = YES;
#elif CL_TARGET_OSX
    shouldIncludeCustomerSupportRequestPreferences = (NSEvent.modifierFlags & NSEventModifierFlagOption) != 0;
#endif

    if (shouldIncludeCustomerSupportRequestPreferences)
    {
        if ([self.customSupportRequestProvider respondsToSelector:@selector(customSupportRequestPreferences)])
            encodedPrefs = [self.customSupportRequestProvider performSelector:@selector(customSupportRequestPreferences)];
        else
            encodedPrefs = makeString(@"Preferences (BASE64): %@", [self.prefsURL.contents base64EncodedStringWithOptions:(NSDataBase64EncodingOptions)0]);
    }
#ifndef SANDBOX
    if ((cc.appCrashLogFilenames).count)
    {
        NSArray <NSString *> *logFilenames = cc.appCrashLogFilenames;
        NSString *crashes = @"";
        for (NSString *path in logFilenames)
        {
            if (![path hasSuffix:@"crash"]) continue;
            
            NSString *token = makeString(@"DSC_%@", path);
            if (!token.defaultInt)
            {
                NSString *additionalCrash = [path.contents.string split:@"/System/Library/"][0];
                if (crashes.length + additionalCrash.length < 100000)
                {
                    crashes = [crashes stringByAppendingString:additionalCrash];
                    token.defaultInt = 1; // we don't wanna send crashes twice, but erasing them is probably not OK
                }
            }
        }
        crashReports = makeString(@"Crash Reports: \n\n%@", crashes);
    }
#endif

    NSString *appName = cc.appName;
    NSString *licenseCode = cc.appChecksumIncludingFrameworksSHA;
    NSString *recipient = OBJECT_OR([bundle objectForInfoDictionaryKey:@"FeedbackEmail"], kFeedbackEmail);
    NSString *udid = @"N/A";
    NSString *architecture = @"Intel";

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
    
#if defined(TARGET_CPU_ARM64) && TARGET_CPU_ARM64
    architecture = @"ARM (Native)";
#else
    int ret = 0;
    size_t size = sizeof(ret);
    sysctlbyname("sysctl.proc_translated", &ret, &size, NULL, 0);
    if (ret > 0)
        architecture = @"ARM (Rosetta)";
#endif

    if (
        !text.length &&
        [self.customSupportRequestProvider respondsToSelector:@selector(customSupportRequestText)]
    )
        text = [self.customSupportRequestProvider performSelector:@selector(customSupportRequestText)]; // we only let customize requests without provided content - those with a normal "contact support" button click
    if ([self.customSupportRequestProvider respondsToSelector:@selector(customSupportRequestAppName)])
        appName = [self.customSupportRequestProvider performSelector:@selector(customSupportRequestAppName)];
    if ([self.customSupportRequestProvider respondsToSelector:@selector(customSupportRequestLicense)])
        licenseCode = [self.customSupportRequestProvider performSelector:@selector(customSupportRequestLicense)];
    
    if (!text) text = @"<Insert Support Request Here>"; // default content if none is provided.

    
    NSString *subject = makeString(@"%@ v%@ (%i) Support Request",
                                   appName,
                                   cc.appVersionString,
                                   cc.appBuildNumber);
    
    NSString *content =  makeString(@"%@\n\n\n\nP.S: Hardware: %@ [%@] Software: %@ Admin: %i UDID: %@\n%@\n%@",
                                    text,
                                    _machineType(),
                                    architecture,
                                    NSProcessInfo.processInfo.operatingSystemVersionString,
                                    _isUserAdmin(),
                                    makeString(@"%@ %@", licenseCode, udid),
                                    encodedPrefs,
                                    crashReports);
    
    
    urlString = makeString(@"mailto:%@?subject=%@&body=%@", recipient, subject, content);
    
    [urlString.escaped.URL open];
}
#endif

- (void)openURL:(CLOpenChoice)choice
{
#if CL_TARGET_OSX
    if (choice == openSupportRequestMail)
    {
        [self sendSupportRequestMail:nil];
        return;
    }
#endif
    
    NSString *urlString = @"";

    if (choice == openBetaSignupMail)
        urlString = makeString(@"s%@?subject=%@ Beta Versions&body=Hello\nI would like to test upcoming beta versions of %@.\nBye\n",
                               [bundle objectForInfoDictionaryKey:@"FeedbackEmail"], cc.appName, cc.appName);
    else if (choice == openHomepageWebsite)
        urlString = OBJECT_OR([bundle objectForInfoDictionaryKey:@"VendorProductPage"],
                              makeString(@"%@%@/", kVendorHomepage, [cc.appName.lowercaseString.words[0] split:@"-"][0]));
    else if (choice == openAppStoreWebsite)
        urlString = [bundle objectForInfoDictionaryKey:@"StoreProductPage"];
    else if (choice == openAppStoreApp)
    {
        NSString *spp = [bundle objectForInfoDictionaryKey:@"StoreProductPage"];
        urlString = [spp replaced:@"https" with:@"macappstore"];
        urlString = [urlString stringByAppendingString:@"&at=1000lwks"];
        
        if (!urlString)
            urlString = [bundle objectForInfoDictionaryKey:@"AlternativetoProductPage"];
    }
    else if (choice == openMacupdaternetWebsite)
    {
        urlString = [bundle objectForInfoDictionaryKey:@"MacupdaternetProductPage"];
        
        if (!urlString)
            urlString = [bundle objectForInfoDictionaryKey:@"FilehorseProductPage"];
    }

    [urlString.escaped.URL open];
}

@end
