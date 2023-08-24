//
//  CLAssert.h
//  MacUpdater
//
//  Created by Carterhaugh LLC on 8/15/23.
//  Copyright © 2023 CoreCode Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

// !!!: ASSERTION MACROS
void fatal(const char *fmt, ...)__printflike(1, 2) __attribute__((noreturn));
#ifdef CUSTOM_ASSERT_FUNCTION   // allows clients to get more info about failures, just def CUSTOM_ASSERT_FUNCTION to a function that sends the string home
    void CUSTOM_ASSERT_FUNCTION(NSString * text);
#define assert_custom(e) (__builtin_expect(!(e), 0) ? CUSTOM_ASSERT_FUNCTION(makeString(@"%@ %@ %i %@", @(__func__), @(__FILE__), __LINE__, @(#e))) : (void)0)
#define assert_custom_info(e, i) (__builtin_expect(!(e), 0) ? CUSTOM_ASSERT_FUNCTION(makeString(@"%@ %@ %i %@  info: %@", @(__func__), @(__FILE__), __LINE__, @(#e), i)) : (void)0)
#else
#define assert_custom(e) assert(e)
#define assert_custom_info(e, i) assert(((e) || ((e) && (i))))
#endif
#define assert_red(e)  \
    ((void) ((e) ? ((void)0) : _assert_red (#e, __FILE__, __LINE__)))
#define _assert_red(e, file, line) \
    ((void)fatal ("\033[91m%s:%d: failed assertion `%s'\033[0m\n", file, line, e))


#ifdef CUSTOM_ASSERT_FUNCTION   // allows clients to get more info about failures, just def CUSTOM_ASSERT_FUNCTION to a function that sends the string home
    void CUSTOM_ASSERT_FUNCTION(NSString * text);
#define assert_custom(e) (__builtin_expect(!(e), 0) ? CUSTOM_ASSERT_FUNCTION(makeString(@"%@ %@ %i %@", @(__func__), @(__FILE__), __LINE__, @(#e))) : (void)0)
#define assert_custom_info(e, i) (__builtin_expect(!(e), 0) ? CUSTOM_ASSERT_FUNCTION(makeString(@"%@ %@ %i %@  info: %@", @(__func__), @(__FILE__), __LINE__, @(#e), i)) : (void)0)
#else
#define assert_custom(e) assert(e)
#define assert_custom_info(e, i) assert(((e) || ((e) && (i))))
#endif
#define assert_red(e)  \
    ((void) ((e) ? ((void)0) : _assert_red (#e, __FILE__, __LINE__)))
#define _assert_red(e, file, line) \
    ((void)fatal ("\033[91m%s:%d: failed assertion `%s'\033[0m\n", file, line, e))
