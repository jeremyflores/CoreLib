//
//  NSLocale+CoreCode.h
//  MacUpdater
//
//  Created by Carterhaugh LLC on 8/16/23.
//  Copyright © 2023 CoreCode Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSLocale (CoreCode)

+ (NSArray <NSString *> *)preferredLanguages2Letter;
+ (NSArray <NSString *> *)preferredLanguages3Letter;

@end
