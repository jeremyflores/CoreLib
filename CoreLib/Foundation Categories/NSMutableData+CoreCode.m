//
//  NSMutableData+CoreCode.m
//  MacUpdater
//
//  Created by Jeremy Flores on 10/3/23.
//  Copyright © 2023 CoreCode Limited. All rights reserved.
//

#import "NSMutableData+CoreCode.h"

@implementation NSMutableData (CoreCode)

-(NSData *)immutableObject {
    return [NSData dataWithData:self];
}

@end
