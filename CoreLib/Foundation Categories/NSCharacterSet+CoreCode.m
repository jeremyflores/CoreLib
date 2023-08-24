//
//  NSCharacterSet+CoreCode.m
//  MacUpdater
//
//  Created by Carterhaugh LLC on 8/16/23.
//  Copyright © 2023 CoreCode Limited. All rights reserved.
//

#import "NSCharacterSet+CoreCode.h"

#import "CLMakers.h"

@implementation NSCharacterSet (CoreCode)

@dynamic stringRepresentation, stringRepresentationLong, mutableObject;

- (NSString *)stringRepresentation
{
    NSString *tmp = @"";
    unichar unicharBuffer[20];
    NSUInteger index = 0;

    for (unichar uc = 0; uc < (0xFFFF); uc ++)
    {
        if ([self characterIsMember:uc])
        {
            unicharBuffer[index] = uc;

            index ++;

            if (index == 20)
            {
                tmp = [tmp stringByAppendingString:[NSString stringWithCharacters:unicharBuffer length:index]];

                index = 0;
            }
        }
    }

    if (index != 0)
        tmp = [tmp stringByAppendingString:[NSString stringWithCharacters:unicharBuffer length:index]];

    return tmp;
}

- (NSString *)stringRepresentationLong
{
    NSString *tmp = @"";

    for (unichar uc = 0; uc < (0xFFFF); uc++)
    {
        if (uc && [self characterIsMember:uc])
        {
            tmp = [tmp stringByAppendingString:makeString(@"unichar %i: %@\n", uc, [NSString stringWithCharacters:&uc length:1])];
        }
    }

    return tmp;
}

- (NSMutableCharacterSet *)mutableObject
{
    return [NSMutableCharacterSet characterSetWithBitmapRepresentation:self.bitmapRepresentation];
}
@end
