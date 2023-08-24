//
//  NSPointerArray+CoreCode.m
//  MacUpdater
//
//  Created by Carterhaugh LLC on 8/16/23.
//  Copyright © 2023 CoreCode Limited. All rights reserved.
//

#import "NSPointerArray+CoreCode.h"

@implementation NSPointerArray (CoreCode)

- (NSInteger)getIndexOfPointer:(void *)aPointer
{
    for (NSUInteger i = 0; i < self.count; i++)
    {
        if ([self pointerAtIndex:i] == aPointer)
        {
            return (NSInteger)i;
        }
    }
    return -1;
}

- (void)forEach:(void (^)(void *))aCallback
{
    for (NSUInteger i = 0; i < self.count; i++)
    {
        aCallback([self pointerAtIndex:i]);
    }
}

- (BOOL)containsPointer:(void *)aPointer
{
    return [self getIndexOfPointer:aPointer] != -1;
}

@end
