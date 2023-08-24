//
//  NSMutableOrderedSet+CoreCode.m
//  MacUpdater
//
//  Created by Carterhaugh LLC on 8/16/23.
//  Copyright © 2023 CoreCode Limited. All rights reserved.
//

#import "NSMutableOrderedSet+CoreCode.h"

@implementation NSMutableOrderedSet (CoreCode)

@dynamic immutableObject;

- (NSOrderedSet *)immutableObject
{
    return [NSOrderedSet orderedSetWithOrderedSet:self];
}

@end
