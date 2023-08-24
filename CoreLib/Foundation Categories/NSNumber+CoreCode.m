//
//  NSNumber+CoreCode.m
//  MacUpdater
//
//  Created by Carterhaugh LLC on 8/16/23.
//  Copyright © 2023 CoreCode Limited. All rights reserved.
//

#import "NSNumber+CoreCode.h"

#import "CLMakers.h"

@implementation NSNumber (CoreCode)

@dynamic literalString;

- (NSString *)literalString
{
    return makeString(@"@(%@)", self.description);
}
@end
