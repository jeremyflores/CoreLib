//
//  NSURLRequest+CoreCode.h
//  MacUpdater
//
//  Created by Carterhaugh LLC on 8/16/23.
//  Copyright © 2023 CoreCode Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLRequest (CoreCode)

- (NSData *)downloadWithTimeout:(double)timeoutSeconds disableCache:(BOOL)disableCache;
@property (readonly, nonatomic) NSData *download;

@end
