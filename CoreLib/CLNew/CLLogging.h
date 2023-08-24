//
//  CLLogging.h
//  MacUpdater
//
//  Created by Carterhaugh LLC on 8/15/23.
//  Copyright © 2023 CoreCode Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(uint8_t, cc_log_type)
{
    CC_LOG_LEVEL_DEBUG   = 7,
    CC_LOG_LEVEL_DEFAULT = 5,
    CC_LOG_LEVEL_ERROR   = 3,
    CC_LOG_LEVEL_FAULT   = 0,
};

void log_to_prefs(NSString *string);
void cc_log_enablecapturetofile(NSURL *fileURL, unsigned long long sizeLimit, cc_log_type minimumLogType);



void cc_log_level(cc_log_type level, NSString *format, ...) NS_FORMAT_FUNCTION(2,3);
#ifdef FORCE_LOG
#define cc_log_debug(...)     cc_log_level(CC_LOG_LEVEL_DEFAULT, __VA_ARGS__)
#elif defined(DEBUG) && !defined(FORCE_NOLOG)
#define cc_log_debug(...)     cc_log_level(CC_LOG_LEVEL_DEBUG, __VA_ARGS__)
#else
#define cc_log_debug(...)
#endif
#define cc_log(...)           cc_log_level(CC_LOG_LEVEL_DEFAULT, __VA_ARGS__)
#define cc_log_error(...)     cc_log_level(CC_LOG_LEVEL_ERROR, __VA_ARGS__)
#define cc_log_emerg(...)     cc_log_level(CC_LOG_LEVEL_FAULT, __VA_ARGS__)

#define LOGFUNCA                cc_log_debug(@"%@ %@ (%p)", self.undoManager.isUndoing ? @"UNDOACTION" : (self.undoManager.isRedoing ? @"REDOACTION" : @"ACTION"), @(__PRETTY_FUNCTION__), (__bridge void *)self);
#define LOGFUNC                    cc_log_debug(@"%@ (%p)", @(__PRETTY_FUNCTION__), (__bridge void *)self);
#define LOGFUNCPARAMA(x)        cc_log_debug(@"%@ %@ (%p) [%@]", self.undoManager.isUndoing ? @"UNDOACTION" : (self.undoManager.isRedoing ? @"REDOACTION" : @"ACTION"), @(__PRETTY_FUNCTION__), (__bridge void *)self, [(x) description]);
#define LOGFUNCPARAM(x)            cc_log_debug(@"%@ (%p) [%@]", @(__PRETTY_FUNCTION__), (__bridge void *)self, [(NSObject *)(x) description]);
#define LOGSUCC                    cc_log_debug(@"success %@ %d", @(__FILE__), __LINE__);
#define LOGFAIL                    cc_log_debug(@"failure %@ %d", @(__FILE__), __LINE__);
#define LOG(x)                    cc_log_debug(@"%@", [(x) description]);
