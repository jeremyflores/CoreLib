//
//  NSDateFormatter+CoreCode.m
//  MacUpdater
//
//  Created by Carterhaugh LLC on 8/16/23.
//  Copyright © 2023 CoreCode Limited. All rights reserved.
//

#import "NSDateFormatter+CoreCode.h"

#import "CLMakers.h"

@implementation NSDateFormatter (CoreCode)

+ (NSString *)formattedTimeFromTimeInterval:(NSTimeInterval)timeInterval
{
    int minutes = (int)(timeInterval / 60);
    int seconds = (int)(timeInterval - (minutes * 60));


    if (minutes)
        return makeString(@"%im %is", minutes, seconds);
    else
        return makeString(@"%is", (int)timeInterval);
}

@end
