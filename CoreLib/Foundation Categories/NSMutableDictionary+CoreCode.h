//
//  NSMutableDictionary+CoreCode.h
//  MacUpdater
//
//  Created by Carterhaugh LLC on 8/16/23.
//  Copyright © 2023 CoreCode Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary <KeyType, ObjectType>(CoreCode)

@property (readonly, nonatomic) NSDictionary <KeyType, ObjectType> *immutableObject;

// 'default dict'
- (void)addObject:(id)object toMutableArrayAtKey:(KeyType)key; // the point here is that it will add a mutablearray with the single object if the key doesn't exist - a poor mans 'defaultdict'


- (void)addEntriesFromDictionaryWithoutOverwritingWithEmptyStrings:(NSDictionary<KeyType, ObjectType> *)otherDictionary;

@end
