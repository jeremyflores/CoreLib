//
//  CLLogging.m
//  MacUpdater
//
//  Created by Carterhaugh LLC on 8/15/23.
//  Copyright © 2023 CoreCode Limited. All rights reserved.
//

#import "CLLogging.h"

#import "CLMakers.h"

#import "Foundation+CoreCode.h"

#undef asl_log
#undef os_log
#if __has_feature(modules) && ((defined(__MAC_OS_X_VERSION_MAX_ALLOWED) && __MAC_OS_X_VERSION_MAX_ALLOWED >= 101200) || (defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && (__IPHONE_OS_VERSION_MAX_ALLOWED >= 100000)))
@import asl;
@import os.log;
#else
#include <asl.h>
#include <os/log.h>
#endif



static NSFileHandle *logfileHandle;
static cc_log_type minimumLogType;

void cc_log_enablecapturetofile(NSURL *fileURL, unsigned long long filesizeLimit, cc_log_type _minimumLogType) // ASL broken on 10.12+ and especially logging to file not working anymore
{
    assert(!logfileHandle);

    if (!fileURL.fileExists)
        [NSData.data writeToURL:fileURL atomically:YES]; // create file with weird API
    else if (filesizeLimit) // truncate first
    {
        NSString *path = fileURL.path;

        NSDictionary *attr = [fileManager attributesOfItemAtPath:path error:NULL];
        NSNumber *fs = attr[NSFileSize];
        unsigned long long filesize = fs.unsignedLongLongValue;

        if (filesize > filesizeLimit)
        {
            NSFileHandle *fh = [NSFileHandle fileHandleForUpdatingURL:fileURL error:nil];

            @try
            {

                [fh seekToFileOffset:(filesize - filesizeLimit)];

                NSData *data = [fh readDataToEndOfFile];

                [fh seekToFileOffset:0];
                [fh writeData:data];
                [fh truncateFileAtOffset:filesizeLimit];
                [fh synchronizeFile];
            }
            @catch (id)
            {
                cc_log_emerg(@"Fatal: your disk is full - please never let that happen again");
            }
            @finally
            {
                [fh closeFile];
            }
        }
    }

    // now open for appending
    logfileHandle = [NSFileHandle fileHandleForUpdatingURL:fileURL error:nil];

    if (!logfileHandle)
    {
        cc_log_error(@"could not open file %@ for log file usage", fileURL.path);
    }
    
    minimumLogType = _minimumLogType;
}

void _cc_log_tologfile(int level, NSString *string)
{
    if (logfileHandle && (level <= minimumLogType))
    {
        static const char* levelNames[8] = {ASL_STRING_EMERG, ASL_STRING_ALERT, ASL_STRING_CRIT, ASL_STRING_ERR, ASL_STRING_WARNING, ASL_STRING_NOTICE, ASL_STRING_INFO, ASL_STRING_DEBUG};
        assert(level < 8);
        NSString *levelStr = @(levelNames[level]);
        NSString *dayString = [NSDate.date stringUsingFormat:@"MMM dd"];
        NSString *timeString = [NSDate.date stringUsingDateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
        NSString *finalString = makeString(@"%@ %@  %@[%i] <%@>: %@\n",
                                           dayString,
                                           timeString,
                                           cc.appName,
                                           NSProcessInfo.processInfo.processIdentifier,
                                           levelStr,
                                           string);

        NSData *data = [finalString dataUsingEncoding:NSUTF8StringEncoding];
        if (data)
        {
            @try
            {
                [logfileHandle seekToEndOfFile];
                [logfileHandle writeData:data];
            }
            @catch (id)
            {
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_FAULT, "%{public}s", "Fatal: your disk is full - please never let that happen again");
            }
        }
        else
        {
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_FAULT, "%{public}s", makeString(@"could not open create data from string '%@' for log", finalString).UTF8String);
        }
    }
}

static NSString *_ccLogToPrefsLock = @"_cc_log_toprefs_LOCK";

void _cc_log_toprefs(int level, NSString *string)
{
#ifndef CLI
#ifndef DONTLOGTOUSERDEFAULTS
    @synchronized (_ccLogToPrefsLock)
    {
        static int lastPosition[8] = {0,0,0,0,0,0,0,0};
        assert(level < 8);
        NSString *key = makeString(@"corelib_asl_lev%i_pos%i", level, lastPosition[level]);
        key.defaultString = makeString(@"date: %@ message: %@", NSDate.date.description, string);
        lastPosition[level]++;
        if (lastPosition[level] > 9)
            lastPosition[level] = 0;
    }
#endif
#endif
}

void cc_log_level(cc_log_type level, NSString *format, ...)
{
    va_list args;
    va_start(args, format);
    NSString *str = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);

    _cc_log_tologfile(level, str);
    _cc_log_toprefs(level, str);

#ifdef CLI
    if (level <= CC_LOG_LEVEL_ERROR)
        fprintf(stderr, "\033[91m%s\033[0m\n", str.UTF8String);
    else if ([str.lowercaseString.trimmedOfWhitespaceAndNewlines hasPrefix:@"warning"])
        fprintf(stderr, "\033[93m%s\033[0m\n", str.UTF8String);
    else
        fprintf(stdout, "%s\n", str.UTF8String);
#else
    const char *utf = str.UTF8String;

    if (level == ASL_LEVEL_DEBUG || level == ASL_LEVEL_INFO)
        os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_DEBUG, "%{public}s", utf);
    else if (level == ASL_LEVEL_NOTICE || level == ASL_LEVEL_WARNING)
        os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_DEFAULT, "%{public}s", utf);
    else if (level == ASL_LEVEL_ERR)
        os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "%{public}s", utf);
    else if (level == ASL_LEVEL_CRIT || level == ASL_LEVEL_ALERT || level == ASL_LEVEL_EMERG)
        os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_FAULT, "%{public}s", utf);
#endif
    
#ifdef DEBUG
    if (level <= CC_LOG_LEVEL_ERROR && ![str containsAny:@[@"Notification: ", @"Alert: ", @"Info: ", @": modal"]])
    {
        // just for breakpoints
    }
#endif
}

void log_to_prefs(NSString *str)
{
    static int lastPosition = 0;

    NSString *key = makeString(@"corelib_logtoprefs_pos%i", lastPosition);

    key.defaultString = makeString(@"date: %@ message: %@", NSDate.date.description, str);

    lastPosition++;

    if (lastPosition > 42)
        lastPosition = 0;
}
