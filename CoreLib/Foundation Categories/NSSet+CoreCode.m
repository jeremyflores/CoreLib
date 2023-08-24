//
//  NSSet+CoreCode.m
//  MacUpdater
//
//  Created by Carterhaugh LLC on 8/16/23.
//  Copyright © 2023 CoreCode Limited. All rights reserved.
//

#import "NSSet+CoreCode.h"

@implementation NSSet (CoreCode)

@dynamic mutableObject;

- (NSMutableSet *)mutableObject
{
    return [NSMutableSet setWithSet:self];
}

@end
