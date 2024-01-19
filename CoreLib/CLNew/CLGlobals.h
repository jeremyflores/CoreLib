//
//  CLGlobals.h
//  MacUpdater
//
//  Created by Carterhaugh LLC on 8/15/23.
//  Copyright © 2023 CoreCode Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CLTarget.h"
#import "CLUIImport.h"

#import <AppKit/AppKit.h>

@class CLCoreLib;

extern CLCoreLib *cc; // init CoreLib with: cc = [[CLCoreLib alloc] initWithCustomSupportRequestProvider:...]
extern NSUserDefaults *userDefaults;
extern NSFileManager *fileManager;
extern NSNotificationCenter *notificationCenter;
extern NSBundle *bundle;

#if CL_TARGET_OSX || CL_TARGET_CLI
extern NSFontManager *fontManager;
extern NSDistributedNotificationCenter *distributedNotificationCenter;
extern NSWorkspace *workspace;
extern NSApplication *application;
extern NSProcessInfo *processInfo;
#endif

// called from `CLCoreLib -init`
void initializeCLGlobals(CLCoreLib *coreLib, NSBundle *bundle, NSUserDefaults *userDefaults);
