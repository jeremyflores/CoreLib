//
//  NSUserDefaults+CoreCode.m
//  MacUpdater
//
//  Created by Carterhaugh LLC on 8/16/23.
//  Copyright © 2023 CoreCode Limited. All rights reserved.
//

#import "NSUserDefaults+CoreCode.h"

#import "CLLogging.h"

#if CL_TARGET_CLI || CL_TARGET_OSX

#ifndef SANDBOX

@implementation NSUserDefaults (CoreCode)

- (NSString *)stringForKey:(NSString *)defaultName ofForeignApp:(NSString *)bundleID
{
    if (!bundleID)
    {
        cc_log_error(@"Error: stringForKey:ofForeignApp: called with nil bundleID");
        return nil;
    }
    NSString *result;
    CFPropertyListRef value = CFPreferencesCopyAppValue((CFStringRef)defaultName, (CFStringRef)bundleID);
    
    if (value && CFGetTypeID(value) == CFStringGetTypeID())
    {
        result = [(__bridge NSString *)value copy];
        CFRelease(value);
    }
    else if (value)
        CFRelease(value);

    
    return result;
}

- (NSObject *)objectForKey:(NSString *)defaultName ofForeignApp:(NSString *)bundleID
{
    if (!bundleID)
    {
        cc_log_error(@"Error: objectForKey:ofForeignApp: called with nil bundleID");
        return nil;
    }
    NSString *result;
    CFPropertyListRef value = CFPreferencesCopyAppValue((CFStringRef)defaultName, (CFStringRef)bundleID);
    
    if (value)
    {
        result = [(__bridge NSObject *)value copy];
        CFRelease(value);
    }
    
    return result;
}

@end
#endif

#endif
