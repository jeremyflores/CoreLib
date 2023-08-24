//
//  NSDictionary+CoreCode.h
//  MacUpdater
//
//  Created by Carterhaugh LLC on 8/16/23.
//  Copyright © 2023 CoreCode Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary <KeyType, ObjectType>(CoreCode)

@property (readonly, nonatomic) NSString *literalString;
@property (readonly, nonatomic) NSData *JSONData;
@property (readonly, nonatomic) NSData *XMLData;
@property (readonly, nonatomic) NSMutableDictionary <KeyType, ObjectType> *mutableObject;
- (NSDictionary *)dictionaryBySettingValue:(ObjectType)value forKey:(KeyType)key; // does replace too
- (NSDictionary *)dictionaryByRemovingKey:(KeyType)key;
- (NSDictionary *)dictionaryByRemovingKeys:(NSArray <KeyType> *)keys;
- (NSDictionary *)dictionaryByReplacingNSNullWithEmptyStrings;
- (BOOL)containsAny:(NSArray <NSString *>*)keys;
- (BOOL)containsAll:(NSArray <NSString *>*)keys;

@end
