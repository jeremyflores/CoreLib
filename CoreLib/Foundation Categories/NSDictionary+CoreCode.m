//
//  NSDictionary+CoreCode.m
//  MacUpdater
//
//  Created by Carterhaugh LLC on 8/16/23.
//  Copyright © 2023 CoreCode Limited. All rights reserved.
//

#import "NSDictionary+CoreCode.h"

#import "CLLogging.h"

#import "NSMutableDictionary+CoreCode.h"
#import "NSObject+CoreCode.h"
#import "NSArray+CoreCode.h"

id SetNullableDictionaryValue(id input) {
    if (input) {
        return input;
    }
    else {
        return [NSNull null];
    }
}

id GetNilDictionaryValue(id value) {
    if (value && ![value isEqual:[NSNull null]]) {
        return value;
    }
    else {
        return nil;
    }
}

@implementation NSDictionary (CoreCode)

@dynamic mutableObject, XMLData, literalString, JSONData;

+ (NSDictionary *)dictionaryByMergingDictionaries:(NSArray<NSDictionary *> *)dictionaries {
    NSDictionary *result = [[self class] dictionaryByMergingDictionaries:dictionaries];

    return result;
}

// if allowsConflicts=NO, and the same key is found in two or more dictionaries, then an NSException will be raised. if allowsConflicts=YES, and the same key is found in two or more dictionaries, then the value found in the dictionary closest to the end of the array will be used.
+ (NSDictionary *)dictionaryByMergingDictionaries:(NSArray<NSDictionary *> *)dictionaries
                                allowingConflicts:(BOOL)allowsConflicts {
    NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionary];

    for (NSDictionary *dictionary in dictionaries) {
        if (!allowsConflicts) {
            NSSet *keysSet = [NSSet setWithArray:dictionary.allKeys];
            NSSet *alreadyExistingKeysSet = [NSSet setWithArray:mutableDictionary.allKeys];

            NSMutableSet *intersectableSet = [NSMutableSet setWithSet:keysSet];
            [intersectableSet intersectSet:alreadyExistingKeysSet];

            if (intersectableSet.count > 0) {
                NSArray *mutualKeysArray = [intersectableSet allObjects];
                NSString *mutualKeysString = [mutualKeysArray componentsJoinedByString:@", "];

                NSString *reasonString = [NSString stringWithFormat:@"Conflict found when attempting to merge dictionaries for keys: %@", mutualKeysString];

                @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                               reason:reasonString
                                             userInfo:nil];
            }
        }
    
        [mutableDictionary addEntriesFromDictionary:dictionary];
    }

    NSDictionary *result = mutableDictionary.immutableObject;

    return result;
}

- (NSString *)literalString
{
    NSMutableString *tmp = [NSMutableString stringWithString:@"@{"];

    for (NSObject *key in self)
    {
        NSObject *value = self[key];
        [tmp appendFormat:@"%@ : %@, ", key.literalString, value.literalString];
    }

    [tmp replaceCharactersInRange:NSMakeRange(tmp.length-2, 2)                // replace trailing ', '
                       withString:@"}"];                                    // with terminating '}'

    return tmp;
}

- (NSData *)JSONData
{
    NSError *err;
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:(NSJSONWritingOptions)0 error:&err];

    if (!data || err)
    {
        cc_log_error(@"Error: JSON write fails! input %@ data %@ err %@", self, data, err);
        return nil;
    }

    return data;
}

- (NSData *)XMLData
{
    NSError *err;
    NSData *data =  [NSPropertyListSerialization dataWithPropertyList:self
                                                               format:NSPropertyListXMLFormat_v1_0
                                                              options:(NSPropertyListWriteOptions)0
                                                                error:&err];

    if (!data || err)
    {
        cc_log_error(@"Error: XML write fails! input %@ data %@ err %@", self, data, err);
        return nil;
    }

    return data;
}

- (NSMutableDictionary *)mutableObject
{
    return [NSMutableDictionary dictionaryWithDictionary:self];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wselector"
    return [super methodSignatureForSelector:@selector(valueForKey:)];
#pragma clang diagnostic pop
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    NSString *propertyName = NSStringFromSelector(invocation.selector);
    invocation.selector = @selector(valueForKey:);
    [invocation setArgument:&propertyName atIndex:2];
    [invocation invokeWithTarget:self];
}

- (NSDictionary *)dictionaryByReplacingNSNullWithEmptyStrings
{
    NSMutableDictionary *mutableCopy = self.mutableCopy;
    NSArray *keys = mutableCopy.allKeys;
    
    for (NSUInteger idx = 0, count = keys.count; idx < count; ++idx)
    {
        id const key = keys[idx];
        id const obj = mutableCopy[key];
        if (obj == NSNull.null)
            mutableCopy[key] = @"";
    }
    
    return mutableCopy.copy;
}

- (NSDictionary *)dictionaryBySettingValue:(id)value forKey:(id)key
{
    NSMutableDictionary *mutable = self.mutableObject;

    mutable[key] = value;

    return mutable.immutableObject;
}

- (NSDictionary *)dictionaryByRemovingKey:(id)key
{
    NSMutableDictionary *mutable = self.mutableObject;

    [mutable removeObjectForKey:key];

    return mutable.immutableObject;
}

- (NSDictionary *)dictionaryByRemovingKeys:(NSArray <NSString *>*)keys
{
    NSMutableDictionary *mutable = self.mutableObject;

    for (NSString *key in keys)
        [mutable removeObjectForKey:key];

    return mutable.immutableObject;
}

- (BOOL)containsAny:(NSArray <NSString *>*)keys
{
    for (NSString *key in keys)
        if (self[key] != nil)
             return YES;
    
    return NO;
}


- (BOOL)containsAll:(NSArray <NSString *>*)keys
{
    for (NSString *key in keys)
        if (self[key] == nil)
            return NO;
    
    return YES;
}

@end