//
//  NSMutableCharacterSet+CoreCode.m
//  MacUpdater
//
//  Created by Carterhaugh LLC on 8/16/23.
//  Copyright © 2023 CoreCode Limited. All rights reserved.
//

#import "NSMutableCharacterSet+CoreCode.h"

@implementation NSMutableCharacterSet (CoreCode)

@dynamic immutableObject;

- (NSCharacterSet *)immutableObject
{
    return [NSCharacterSet characterSetWithBitmapRepresentation:self.bitmapRepresentation];
}
@end
