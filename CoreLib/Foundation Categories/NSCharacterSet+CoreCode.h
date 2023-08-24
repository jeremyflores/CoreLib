//
//  NSCharacterSet+CoreCode.h
//  MacUpdater
//
//  Created by Carterhaugh LLC on 8/16/23.
//  Copyright © 2023 CoreCode Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSCharacterSet (CoreCode)

@property (readonly, nonatomic) NSMutableCharacterSet *mutableObject;
@property (readonly, nonatomic) NSString *stringRepresentation;
@property (readonly, nonatomic) NSString *stringRepresentationLong;

@end
