//
//  CLMakers.h
//  MacUpdater
//
//  Created by Carterhaugh LLC on 8/15/23.
//  Copyright © 2023 CoreCode Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CLUIImport.h"

#define MAKE_MAKER(classname) \
static inline NS ## classname * make ## classname (void) { return (NS ## classname *)[NS ## classname new];}
MAKE_MAKER(MutableArray)
MAKE_MAKER(MutableDictionary)
MAKE_MAKER(MutableIndexSet)
MAKE_MAKER(MutableString)
MAKE_MAKER(MutableSet)

NSString *makeStringC(const char * __restrict, ...);
NSString *makeString(NSString *format, ...) NS_FORMAT_FUNCTION(1,2);
NSString *makeLocalizedString(NSString *format, ...)  NS_FORMAT_FUNCTION(1,2);

#if CL_TARGET_IOS || CL_TARGET_OSX
NSValue *makeRectValue(CGFloat x, CGFloat y, CGFloat width, CGFloat height);
#endif

NSString *makeTempDirectory(BOOL useReplacementDirectory); // if YES folder inside "replacement directory" ($(TMPDIR)/TemporaryItems), otherwise folder inside $(TMPDIR). previously it would default to YES
NSString *makeTempFilepath(NSString *extension);
NSPredicate *makePredicate(NSString *format, ...);
NSString *makeDescription(NSObject *sender, NSArray *args);
#if defined(__clang_analyzer__) && __clang_analyzer__
#define makeDictionaryOfVariables(...)  ((NSDictionary *)(@[ __VA_ARGS__ ])) // find crashes with primitive values iff in analyzer
#else
#define makeDictionaryOfVariables(...) _makeDictionaryOfVariables(@"" # __VA_ARGS__, __VA_ARGS__, nil) // like NSDictionaryOfVariableBindings() but safe in case of nil values
#endif
NSDictionary<NSString *, id> * _makeDictionaryOfVariables(NSString * commaSeparatedKeysString, id firstValue, ...); // not for direct use

#if CL_TARGET_OSX
NSColor *makeColor(CGFloat r, CGFloat g, CGFloat b, CGFloat a);        // params from 0..1
NSColor *makeColor255(CGFloat r, CGFloat g, CGFloat b, CGFloat a);    // params from 0..255
#elif CL_TARGET_IOS
UIColor *makeColor(CGFloat r, CGFloat g, CGFloat b, CGFloat a);
UIColor *makeColor255(CGFloat r, CGFloat g, CGFloat b, CGFloat a);
#endif
