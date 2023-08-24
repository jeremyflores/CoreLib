//
//  NSOrderedSet+CoreCode.m
//  MacUpdater
//
//  Created by Carterhaugh LLC on 8/16/23.
//  Copyright © 2023 CoreCode Limited. All rights reserved.
//

#import "NSOrderedSet+CoreCode.h"

@implementation NSOrderedSet (CoreCode)

@dynamic mutableObject;


- (NSMutableOrderedSet *)mutableObject
{
    return [NSMutableOrderedSet orderedSetWithOrderedSet:self];
}


@end
