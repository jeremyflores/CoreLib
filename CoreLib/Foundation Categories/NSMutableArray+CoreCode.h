//
//  NSMutableArray+CoreCode.h
//  MacUpdater
//
//  Created by Carterhaugh LLC on 8/16/23.
//  Copyright © 2023 CoreCode Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray <ObjectType>(CoreCode)

@property (readonly, nonatomic) NSArray <ObjectType> *immutableObject;

- (void)addNewObject:(ObjectType)anObject;
- (void)addObjectSafely:(ObjectType)anObject;
- (void)map:(ObjectType (^)(ObjectType input))block;
- (void)filter:(int (^)(ObjectType input))block;
- (void)filterUsingPredicateString:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);
- (void)removeFirstObject;
- (void)moveObjectAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;
- (void)removeObjectPassingTest:(int (^)(ObjectType input))block;

@end
