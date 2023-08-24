//
//  CLUserDefaults.m
//  MacUpdater
//
//  Created by Carterhaugh LLC on 8/15/23.
//  Copyright © 2023 CoreCode Limited. All rights reserved.
//

#import "CLUserDefaults.h"

#import "Foundation+CoreCode.h"

void cc_defaults_addtoarray(NSString *key, NSObject *entry, NSUInteger maximumEntries)
{
    NSArray *currentArray = [NSUserDefaults.standardUserDefaults objectForKey:key];
    
    if (!currentArray || ![currentArray isKindOfClass:NSArray.class])
        currentArray = @[];
        
    currentArray = [currentArray arrayByAddingObject:entry];
    
    while (currentArray.count > maximumEntries)
        currentArray = [currentArray arrayByRemovingObjectAtIndex:0];
    
    [NSUserDefaults.standardUserDefaults setObject:currentArray forKey:key];
}
