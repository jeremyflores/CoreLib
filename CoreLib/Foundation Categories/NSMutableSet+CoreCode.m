//
//  NSMutableSet+CoreCode.m
//  MacUpdater
//
//  Created by Carterhaugh LLC on 8/16/23.
//  Copyright © 2023 CoreCode Limited. All rights reserved.
//

#import "NSMutableSet+CoreCode.h"

@implementation NSMutableSet (CoreCode)

@dynamic immutableObject;

- (NSSet *)immutableObject
{
    return [NSSet setWithSet:self];
}

- (void)addObjectSafely:(id)anObject
{
    if (anObject)
        [self addObject:anObject];
}

@end
