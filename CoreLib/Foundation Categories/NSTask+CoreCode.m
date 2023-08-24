//
//  NSTask+CoreCode.m
//  MacUpdater
//
//  Created by Carterhaugh LLC on 8/16/23.
//  Copyright © 2023 CoreCode Limited. All rights reserved.
//

#import "NSTask+CoreCode.h"

#if CL_TARGET_CLI || CL_TARGET_OSX
@implementation NSTask (CoreCode)

- (BOOL)waitUntilExitWithTimeout:(NSTimeInterval)timeout
{
    NSDate *killDate = [NSDate dateWithTimeIntervalSinceNow:timeout];
    BOOL killed = NO;
    
    while (self.running)
    {
        if ([[NSDate date] laterDate:killDate] != killDate)
        {
            [self terminate];
            killed = YES;
        }
        [NSThread sleepForTimeInterval:0.05];
    }
    
    return killed;
}

@end
#endif
