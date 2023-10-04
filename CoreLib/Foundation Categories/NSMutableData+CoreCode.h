//
//  NSMutableData+CoreCode.h
//  MacUpdater
//
//  Created by Jeremy Flores on 10/3/23.
//  Copyright © 2023 CoreCode Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableData (CoreCode)

-(NSData *)immutableObject;

@end

NS_ASSUME_NONNULL_END
