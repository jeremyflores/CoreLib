//
//  NSData+CoreCode.h
//  MacUpdater
//
//  Created by Carterhaugh LLC on 8/16/23.
//  Copyright © 2023 CoreCode Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (CoreCode)

@property (readonly, nonatomic) NSMutableData *mutableObject;
@property (readonly, nonatomic) NSString *string;
@property (readonly, nonatomic) NSString *stringUTF8;
@property (readonly, nonatomic) NSString *hexString;
@property (readonly, nonatomic) NSString *base64String;
@property (readonly, nonatomic) NSDictionary *JSONDictionary;
@property (readonly, nonatomic) NSArray *JSONArray;
#ifdef USE_SNAPPY
@property (readonly, nonatomic) NSData *snappyCompressed;
@property (readonly, nonatomic) NSData *snappyDecompressed;
#endif
#ifdef USE_SECURITY
@property (readonly, nonatomic) NSString *SHA1;             // 20 byte - 160 bit
@property (readonly, nonatomic) NSString *SHA256;         // 32 byte - 256 bit
#endif
@property (readonly, nonatomic) NSRange fullRange;
- (NSData *)xorWith:(NSData *)key;

@end
