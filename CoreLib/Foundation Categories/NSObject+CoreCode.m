//
//  NSObject+CoreCode.m
//  MacUpdater
//
//  Created by Carterhaugh LLC on 8/16/23.
//  Copyright © 2023 CoreCode Limited. All rights reserved.
//

#import "NSObject+CoreCode.h"

#import "CLMakers.h"

#import "CLConstantKey.h"

#if __has_feature(modules)
@import ObjectiveC.runtime;
#else
#import <objc/runtime.h>
#endif


CONST_KEY(CoreCodeAssociatedValue)

@implementation NSObject (CoreCode)

@dynamic associatedValue, id, literalString;


- (void)setAssociatedValue:(id)value forKey:(const NSString *)key
{
#if    TARGET_OS_IPHONE
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-objc-pointer-introspection"
    BOOL is64Bit = sizeof(void *) == 8;
    BOOL isTagged = ((uintptr_t)self & 0x1);
    assert(!(is64Bit && isTagged)); // associated values on tagged pointers broken on 64 bit iOS
#pragma clang diagnostic pop
#endif

    objc_setAssociatedObject(self, (__bridge const void *)(key), value, OBJC_ASSOCIATION_RETAIN);
}

- (id)associatedValueForKey:(const NSString *)key
{
    id value = objc_getAssociatedObject(self, (__bridge const void *)(key));

    return value;
}

- (void)setAssociatedValue:(id)value
{
    [self setAssociatedValue:value forKey:kCoreCodeAssociatedValueKey];
}

- (id)associatedValue
{
    return [self associatedValueForKey:kCoreCodeAssociatedValueKey];
}

+ (instancetype)newWith:(NSDictionary *)dict
{
    NSObject *obj = [self new];
    for (NSString *key in dict)
    {
        [obj setValue:dict[key] forKey:key];
    }

    return obj;
}

- (id)id
{
    return (id)self;
}

- (NSString *)stringValue
{
    return self.description;   // MacUpdater: its ultra ultra rare but at least one app out there has the bundle version as an array. in any case, making stringValue something that always works is a good idea
}

- (NSString *)literalString
{
    return makeString(@"-unsupportedLiteralObject: %@-", self.description);
}

//- (instancetype)non_null
//{
//    return self;
//}
@end
