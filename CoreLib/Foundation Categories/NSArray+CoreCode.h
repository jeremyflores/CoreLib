//
//  NSArray+CoreCode.h
//  MacUpdater
//
//  Created by Carterhaugh LLC on 8/16/23.
//  Copyright © 2023 CoreCode Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CLTarget.h"
#import "CLTypes.h"

@interface NSArray <ObjectType> (CoreCode)

@property (readonly, nonatomic) NSArray *flattenedArray;
@property (readonly, nonatomic) NSArray <ObjectType> *reverseArray;
@property (readonly, nonatomic) NSMutableArray <ObjectType> *mutableObject;
@property (readonly, nonatomic) BOOL empty;
@property (readonly, nonatomic) NSData *XMLData;
@property (readonly, nonatomic) NSData *JSONData;
@property (readonly, nonatomic) NSString *string;
@property (readonly, nonatomic) NSString *path;
@property (readonly, nonatomic) NSArray <ObjectType> *sorted;
@property (readonly, nonatomic) NSString *literalString;
@property (readonly, nonatomic) NSDictionary *dictionary; // will yield a dictionary that has the array contents as keys and @(1) as objects

- (NSArray <ObjectType>*)arrayByAddingObjectSafely:(ObjectType)anObject;            // add nil aint a prob
- (NSArray <ObjectType>*)arrayByAddingNewObject:(ObjectType)anObject;            // adds the object only if it is not identical (contentwise) to existing entry
- (NSArray <ObjectType>*)arrayByRemovingObject:(ObjectType)anObject;            // this will also remove objects that are considered equal, i.e. strings with same content
- (NSArray <ObjectType>*)arrayByRemovingObjects:(NSArray <ObjectType>*)objects;
- (NSArray <ObjectType>*)arrayByRemovingObjectIdenticalTo:(ObjectType)anObject; // identical to only erases the *same* object, i.e. same memory address.
- (NSArray <ObjectType>*)arrayByRemovingObjectsIdenticalTo:(NSArray <ObjectType>*)objects;
- (NSArray <ObjectType>*)arrayByRemovingObjectAtIndex:(NSUInteger)index;
- (NSArray <ObjectType>*)arrayByRemovingObjectsAtIndexes:(NSIndexSet *)indexSet;
- (NSArray *)arrayByInsertingObject:(id)anObject atIndex:(NSUInteger)index;
- (NSArray <ObjectType>*)arrayByReplacingObject:(ObjectType)anObject withObject:(ObjectType)newObject;
- (ObjectType)slicingObjectAtIndex:(NSInteger)index; // -1 is lastObject -2 is penultimateObject
- (ObjectType)safeSlicingObjectAtIndex:(NSInteger)index; // -1 is lastObject -2 is penultimateObject
- (ObjectType)safeObjectAtIndex:(NSUInteger)index;
- (BOOL)containsDictionaryWithKey:(NSString *)key equalTo:(NSString *)value;
- (NSArray <ObjectType>*)sortedArrayByKey:(NSString *)key;
- (NSArray <ObjectType>*)sortedArrayByKey:(NSString *)key insensitive:(BOOL)insensitive;
- (NSArray <ObjectType>*)sortedArrayByKey:(NSString *)key ascending:(BOOL)ascending;
- (BOOL)contains:(ObjectType)object;                                // shortcut = containsObject
- (BOOL)containsString:(NSString *)str insensitive:(BOOL)insensitive;
- (BOOL)containsObjectIdenticalTo:(ObjectType)object;               // similar: indexOfObjectIdenticalTo != NSNotFound

- (CCIntRange2D)calculateExtentsOfPoints:(CCIntPoint (^)(ObjectType input))block;
- (CCIntRange1D)calculateExtentsOfValues:(int (^)(ObjectType input))block;

- (NSArray <ObjectType>*)clamp:(NSUInteger)maximumLength;


- (NSArray <ObjectType>*)subarrayFromIndex:(NSUInteger)index;       //  containing the characters of the receiver from the one at anIndex to the end (DOES include index)  similar to -[NSString subarrayFromIndex:]
- (NSArray <ObjectType>*)subarrayToIndex:(NSUInteger)index;         //  containing the characters of the receiver up to, but not including, the one at anIndex. (does NOT include index) similar to -[NSString substringToIndex:]

- (NSArray <ObjectType>*)slicingSubarrayToIndex:(NSInteger)index;   // index should be negative and tell how many objects to remove from the end ...  -1 removes one char from the end
- (NSArray <ObjectType>*)slicingSubarrayFromIndex:(NSInteger)index; // index should be negative and tell how many chars to include from the end .... -2 is just the last two items


#if CL_TARGET_CLI || CL_TARGET_OSX
- (NSString *)runAsTask;
- (NSString *)runAsTaskWithTerminationStatus:(NSInteger *)terminationStatus;


- (NSString *)runAsTaskWithProgressBlock:(StringInBlock)progressBlock; // warning: the string may be nil
- (NSString *)runAsTaskWithProgressBlock:(StringInBlock)progressBlock terminationStatus:(NSInteger *)terminationStatus;
#endif

- (NSArray *)mapped:(id (^)(ObjectType input))block;
- (NSArray <ObjectType>*)filtered:(BOOL (^)(ObjectType input))block;
- (NSArray <ObjectType>*)filteredUsingPredicateString:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);
- (NSInteger)reduce:(int (^)(ObjectType input))block;

// versions similar to cocoa methods
- (void)apply:(void (^)(ObjectType input))block;                // similar = enumerateObjectsUsingBlock:

// forwards for less typing
- (NSString *)joined:(NSString *)sep;                            // shortcut = componentsJoinedByString:

@property (readonly, nonatomic) NSString *joinedWithSpaces;
@property (readonly, nonatomic) NSString *joinedWithCommasAndSpaces;
@property (readonly, nonatomic) NSString *joinedWithNewlines;
@property (readonly, nonatomic) NSString *joinedWithDots;
@property (readonly, nonatomic) NSString *joinedWithCommas;


@property (readonly, nonatomic) NSSet <ObjectType> *set;
@property (readonly, nonatomic) NSOrderedSet <ObjectType> *orderedSet;

@property (readonly, nonatomic) ObjectType mostFrequentObject;
@property (readonly, nonatomic) ObjectType randomObject;

@property (readonly, nonatomic) NSRange fullRange;

@end
