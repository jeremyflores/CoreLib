//
//  NSMutableArray+CoreCode.m
//  MacUpdater
//
//  Created by Carterhaugh LLC on 8/16/23.
//  Copyright © 2023 CoreCode Limited. All rights reserved.
//

#import "NSMutableArray+CoreCode.h"

#import "CLTypes.h"

@implementation  NSMutableArray (CoreCode)

@dynamic immutableObject;

- (void)moveObjectAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex
{
    id object = self[fromIndex];
    [self removeObjectAtIndex:fromIndex];

    if (toIndex < self.count)
        [self insertObject:object atIndex:toIndex];
    else
        [self addObject:object];
}

- (void)removeObjectPassingTest:(ObjectInIntOutBlock)block
{
    NSUInteger idx = [self indexOfObjectPassingTest:^BOOL(id obj, NSUInteger i, BOOL *s)
    {
        int res = block(obj);
        return (BOOL)res;
    }];

    if (idx != NSNotFound)
        [self removeObjectAtIndex:idx];
}

- (NSArray *)immutableObject
{
    return [NSArray arrayWithArray:self];
}

- (void)addNewObject:(id)anObject
{
    if (anObject && [self indexOfObject:anObject] == NSNotFound)
        [self addObject:anObject];
}

- (void)addObjectSafely:(id)anObject
{
    if (anObject)
        [self addObject:anObject];
}

- (void)map:(ObjectInOutBlock)block
{
    for (NSUInteger i = 0; i < self.count; i++)
    {
        id result = block(self[i]);

        self[i] = result;
    }
}

- (void)filter:(ObjectInIntOutBlock)block
{
    NSMutableIndexSet *indices = [NSMutableIndexSet new];

    for (NSUInteger i = 0; i < self.count; i++)
    {
        int result = block(self[i]);
        if (!result)
            [indices addIndex:i];
    }


    [self removeObjectsAtIndexes:indices];
}

- (void)filterUsingPredicateString:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    NSPredicate *pred = [NSPredicate predicateWithFormat:format arguments:args];
    va_end(args);

    [self filterUsingPredicate:pred];
}

- (void)removeFirstObject
{
    [self removeObjectAtIndex:0];
}
@end
