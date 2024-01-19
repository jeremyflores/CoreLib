//
//  CLGlobals.h
//  MacUpdater
//
//  Created by Carterhaugh LLC on 8/15/23.
//  Copyright © 2023 CoreCode Limited. All rights reserved.
//

#import "CLGlobals.h"

#import "CLCoreLib.h"

CLCoreLib *cc;
NSUserDefaults *userDefaults;
NSFileManager *fileManager;
NSNotificationCenter *notificationCenter;
NSBundle *bundle;

#if CL_TARGET_OSX || CL_TARGET_CLI
NSFontManager *fontManager;
NSDistributedNotificationCenter *distributedNotificationCenter;
NSApplication *application;
NSWorkspace *workspace;
NSProcessInfo *processInfo;
#endif

void initializeCLGlobals(CLCoreLib *coreLib, NSBundle *_bundle, NSUserDefaults *_userDefaults) {
    cc = coreLib;

    userDefaults = _userDefaults;

    fileManager = NSFileManager.defaultManager;
    notificationCenter = NSNotificationCenter.defaultCenter;
    bundle = _bundle;

// AppKit-specific globals
#if CL_TARGET_OSX || CL_TARGET_CLI
    fontManager = NSFontManager.sharedFontManager;
    distributedNotificationCenter = NSDistributedNotificationCenter.defaultCenter;
    workspace = NSWorkspace.sharedWorkspace;
    application = NSApplication.sharedApplication;
    processInfo = NSProcessInfo.processInfo;
#endif
}
