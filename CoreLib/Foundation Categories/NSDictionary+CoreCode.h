//
//  NSDictionary+CoreCode.h
//  MacUpdater
//
//  Created by Carterhaugh LLC on 8/16/23.
//  Copyright © 2023 CoreCode Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

id SetNullableDictionaryValue(id input);
id GetNilDictionaryValue(id value);

@interface NSDictionary <KeyType, ObjectType>(CoreCode)

@property (readonly, nonatomic) NSString *literalString;
@property (readonly, nonatomic) NSData *JSONData;
@property (readonly, nonatomic) NSData *XMLData;
@property (readonly, nonatomic) NSMutableDictionary <KeyType, ObjectType> *mutableObject;

// convenience method that calls +dictionaryByMergingDictionaries:allowingConflicts: with allowsConflicts=YES
+ (NSDictionary<KeyType, ObjectType> *)dictionaryByMergingDictionaries:(NSArray<NSDictionary *> *)dictionaries;

// if allowsConflicts=NO, and the same key is found in two or more dictionaries, then an NSException will be raised. if allowsConflicts=YES, and the same key is found in two or more dictionaries, then the value found in the dictionary closest to the end of the array will be used.
+ (NSDictionary<KeyType, ObjectType> *)dictionaryByMergingDictionaries:(NSArray<NSDictionary *> *)dictionaries
                                allowingConflicts:(BOOL)allowsConflicts;

- (NSDictionary *)dictionaryBySettingValue:(ObjectType)value forKey:(KeyType)key; // does replace too
- (NSDictionary *)dictionaryByRemovingKey:(KeyType)key;
- (NSDictionary *)dictionaryByRemovingKeys:(NSArray <KeyType> *)keys;
- (NSDictionary *)dictionaryByReplacingNSNullWithEmptyStrings;
- (BOOL)containsAny:(NSArray <NSString *>*)keys;
- (BOOL)containsAll:(NSArray <NSString *>*)keys;

@end
