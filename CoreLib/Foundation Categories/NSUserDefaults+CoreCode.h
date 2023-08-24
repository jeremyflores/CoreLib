//
//  NSUserDefaults+CoreCode.h
//  MacUpdater
//
//  Created by Carterhaugh LLC on 8/16/23.
//  Copyright © 2023 CoreCode Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CLTarget.h"

#if CL_TARGET_CLI || CL_TARGET_OSX

#ifndef SANDBOX
@interface NSUserDefaults (CoreCode)

- (NSString *)stringForKey:(NSString *)defaultName ofForeignApp:(NSString *)bundleID;
- (NSObject *)objectForKey:(NSString *)defaultName ofForeignApp:(NSString *)bundleID;

@end
#endif

#endif
