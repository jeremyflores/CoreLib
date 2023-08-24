//
//  NSObject+CoreCode.h
//  MacUpdater
//
//  Created by Carterhaugh LLC on 8/16/23.
//  Copyright © 2023 CoreCode Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (CoreCode)

@property (readonly, nonatomic) id id;

@property (readonly, nonatomic) NSString *literalString;
@property (retain, nonatomic) id associatedValue;

- (id)associatedValueForKey:(const NSString *)key;
- (void)setAssociatedValue:(id)value forKey:(const NSString *)key;

+ (instancetype)newWith:(NSDictionary *)dict;

// - (instancetype _Nonnull)non_null; // doesn't seem to work for a weird reason


@end
