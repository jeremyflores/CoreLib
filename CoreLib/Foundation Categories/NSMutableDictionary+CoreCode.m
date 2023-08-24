//
//  NSMutableDictionary+CoreCode.m
//  MacUpdater
//
//  Created by Carterhaugh LLC on 8/16/23.
//  Copyright © 2023 CoreCode Limited. All rights reserved.
//

#import "NSMutableDictionary+CoreCode.h"

@implementation NSMutableDictionary (CoreCode)

@dynamic immutableObject;

- (NSDictionary *)immutableObject
{
    return [NSDictionary dictionaryWithDictionary:self];
}

- (void)addObject:(id)object toMutableArrayAtKey:(id)key
{
    NSMutableArray *existingEntry = self[key];
    
    if (existingEntry)
        [existingEntry addObject:object];
    else
        self[key] = [NSMutableArray arrayWithObject:object];
}

- (void)addEntriesFromDictionaryWithoutOverwritingWithEmptyStrings:(NSDictionary *)otherDictionary
{
    NSMutableDictionary *otherDictionaryCopy = [otherDictionary mutableCopy];
    
    for (NSString *key in otherDictionaryCopy.allKeys)
        if (self[key] &&
            [((NSObject *)otherDictionaryCopy[key]) isKindOfClass:NSString.class] &&
            !((NSString *)otherDictionaryCopy[key]).length)
            [otherDictionaryCopy removeObjectForKey:key];
    
    [self addEntriesFromDictionary:otherDictionaryCopy];
}

@end
