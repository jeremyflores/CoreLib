//
//  NSMutableOrderedSet+CoreCode.h
//  MacUpdater
//
//  Created by Carterhaugh LLC on 8/16/23.
//  Copyright © 2023 CoreCode Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableOrderedSet <ObjectType> (CoreCode)

@property (readonly, nonatomic) NSOrderedSet <ObjectType> *immutableObject;

@end
