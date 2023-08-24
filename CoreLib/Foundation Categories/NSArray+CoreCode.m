//
//  NSArray+CoreCode.m
//  MacUpdater
//
//  Created by Carterhaugh LLC on 8/16/23.
//  Copyright © 2023 CoreCode Limited. All rights reserved.
//

#import "NSArray+CoreCode.h"

#import "CLMakers.h"
#import "CLConvenience.h"
#import "CLLogging.h"
#import "CLRandom.h"
#import "CLSwifty.h"

#import "NSMutableArray+CoreCode.h"
#import "NSData+CoreCode.h"
#import "NSMutableDictionary+CoreCode.h"
#import "NSObject+CoreCode.h"
#import "NSString+CoreCode.h"

@implementation NSArray (CoreCode)


@dynamic mutableObject, empty, set, reverseArray, string, path, sorted, XMLData, flattenedArray, literalString, orderedSet, JSONData, mostFrequentObject, dictionary, randomObject, joinedWithSpaces, joinedWithNewlines, joinedWithDots, joinedWithCommas, fullRange;


- (NSRange)fullRange
{
    return NSMakeRange(0, self.count);
}

- (NSDictionary *)dictionary
{
    NSNumber *oneObject = @(1);
    NSMutableDictionary *result = makeMutableDictionary();
 
    for (id object in self)
        result[object] = oneObject;
    
    return result.immutableObject;
}

- (NSString *)literalString
{
    NSMutableString *tmp = [NSMutableString stringWithString:@"@["];

    for (NSObject *obj in self)
        [tmp appendFormat:@"%@, ", obj.literalString];

    [tmp replaceCharactersInRange:NSMakeRange(tmp.length-2, 2)                // replace trailing ', '
                       withString:@"]"];                        // with terminating ']'

    return tmp;
}

- (id)randomObject
{
    if (!self.count) return nil;
    else
        return self[(NSUInteger)generateRandomIntBetween(0,(int)self.count-1)];
}

- (NSArray *)clamp:(NSUInteger)maximumLength
{
    return ((self.count <= maximumLength) ? self : [self subarrayToIndex:maximumLength]);
}


- (id)mostFrequentObject
{
//    NSCountedSet *set = [[NSCountedSet alloc] initWithArray:self]; // this seems to be slower than a two-loop solution, at least for small arrays
//    id mostFrequentObject = nil;
//    NSUInteger highestCount = 0;
//
//    for (id obj in set)
//    {
//        NSUInteger count = [set countForObject:obj];
//
//        if (count > highestCount)
//        {
//            highestCount = count;
//            mostFrequentObject = obj;
//        }
//    }

    
    let objToCount = (NSMutableDictionary <NSObject *, NSNumber *> *) makeMutableDictionary();
    for (id obj in self)
    {
        objToCount[obj] = @([objToCount[obj] intValue] + 1);
    }
    
    int highestCount = 0;
    id highestObj;
    
    for (id obj in self)
    {
        int thisCount = [objToCount[obj] intValue];
        
        if (thisCount > highestCount)
        {
            highestCount = thisCount;
            highestObj = obj;
        }
    }

    return highestObj;
}

- (NSString *)stringValue
{
    return self.joinedWithSpaces;   // MacUpdater: its ultra ultra rare but at least one app out there has the bundle version as an array. in any case, making stringValue something that always works is a good idea
}

- (NSArray *)sorted
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wselector"
    return [self sortedArrayUsingSelector:@selector(compare:)];
#pragma clang diagnostic pop
}


- (NSData *)JSONData
{
    NSError *err;
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:(NSJSONWritingOptions)0 error:&err];

    if (!data || err)
    {
        cc_log_error(@"Error: JSON write fails! input %@ data %@ err %@", self, data, err);
        return nil;
    }

    return data;
}


- (NSData *)XMLData
{
    NSError *err;
    NSData *data =  [NSPropertyListSerialization dataWithPropertyList:self
                                                               format:NSPropertyListXMLFormat_v1_0
                                                              options:(NSPropertyListWriteOptions)0
                                                                error:&err];

    if (!data || err)
    {
        cc_log_error(@"Error: XML write fails! input %@ data %@ err %@", self, data, err);
        return nil;
    }

    return data;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu-statement-expression"

- (CCIntRange2D)calculateExtentsOfPoints:(ObjectInPointOutBlock)block
{
    CCIntRange2D range = {{INT_MAX, INT_MAX}, {INT_MIN, INT_MIN}, {-1, -1}};

    if (self.count)
    {
        for (NSObject *o in self)
        {
            CCIntPoint p = block(o);

            range.max.x = MAX(range.max.x, p.x);
            range.max.y = MAX(range.max.y, p.y);
            range.min.x = MIN(range.min.x, p.x);
            range.min.y = MIN(range.min.y, p.y);
        }

        range.length.x = range.max.x - range.min.x;
        range.length.y = range.max.y - range.min.y;
    }



    return range;
}


- (CCIntRange1D)calculateExtentsOfValues:(ObjectInIntOutBlock)block
{
    CCIntRange1D range = {INT_MAX, INT_MIN, -1};

    if (self.count)
    {
        for (NSObject *o in self)
        {
            int p = block(o);

            range.min = MIN(range.min, p);
            range.max = MAX(range.max, p);
        }

        range.length = range.max - range.min;
    }
    
    return range;
}
#pragma clang diagnostic pop


+ (void)_addArrayContents:(NSArray *)array toArray:(NSMutableArray *)newArray
{
    for (NSObject *object in array)
    {
        if ([object isKindOfClass:[NSArray class]])
            [NSArray _addArrayContents:(NSArray *)object toArray:newArray];
        else
            [newArray addObject:object];
    }
}


- (NSArray *)flattenedArray
{
    NSMutableArray *tmp = [NSMutableArray array];

    [NSArray _addArrayContents:self toArray:tmp];

    return tmp.immutableObject;
}


- (NSString *)string
{
    NSString *ret = @"";

    for (NSString *str in self)
        ret = [ret stringByAppendingString:VALID_STR(str)];

    return ret;
}


- (NSString *)path
{
    NSString *ret = @"";
    
    for (NSString *str in self)
        ret = [ret stringByAppendingPathComponent:str];

    return ret;
}


- (BOOL)contains:(id)object
{
    return [self containsObject:object];
}

- (BOOL)containsString:(NSString *)str insensitive:(BOOL)insensitive
{
    for (NSString *string in self)
    {
        if ([string contains:str insensitive:insensitive] && str.length && string.length)
            return YES;
    }
    return NO;
}


- (BOOL)containsObjectIdenticalTo:(id)object
{
    return [self indexOfObjectIdenticalTo:object] != NSNotFound;
}

- (NSArray *)reverseArray
{
    return [self reverseObjectEnumerator].allObjects;
}


- (NSOrderedSet *)orderedSet
{
    return [NSOrderedSet orderedSetWithArray:self];
}

- (NSSet *)set
{
    return [NSSet setWithArray:self];
}

- (NSArray *)arrayByInsertingObject:(id)anObject atIndex:(NSUInteger)index
{
    NSMutableArray *array = [NSMutableArray arrayWithArray:self];

    [array insertObject:anObject atIndex:index];

    return [NSArray arrayWithArray:array];
}

- (NSArray *)arrayByAddingObjectSafely:(id)anObject
{
    if (!anObject)
        return self;
    else
        return [self arrayByAddingObject:anObject];
}

- (NSArray *)arrayByAddingNewObject:(id)anObject
{
    if ([self indexOfObject:anObject] == NSNotFound)
        return [self arrayByAddingObject:anObject];
    else
        return self;
}

- (NSArray *)arrayByRemovingObject:(id)anObject
{
    NSMutableArray *array = [NSMutableArray arrayWithArray:self];

    [array removeObject:anObject];

    return [NSArray arrayWithArray:array];
}


- (NSArray *)arrayByRemovingObjects:(NSArray *)objects
{
    NSMutableArray *array = [NSMutableArray arrayWithArray:self];

    [array removeObjectsInArray:objects];

    return [NSArray arrayWithArray:array];
}


- (NSArray *)arrayByRemovingObjectIdenticalTo:(id)anObject
{
    NSMutableArray *array = [NSMutableArray arrayWithArray:self];

    [array removeObjectIdenticalTo:anObject];

    return [NSArray arrayWithArray:array];
}


- (NSArray *)arrayByRemovingObjectsIdenticalTo:(NSArray *)objects
{
    NSMutableArray *array = [NSMutableArray arrayWithArray:self];

    for (id obj in objects)
        [array removeObjectIdenticalTo:obj];

    return [NSArray arrayWithArray:array];
}


- (NSArray *)arrayByRemovingObjectsAtIndexes:(NSIndexSet *)indexSet
{
    NSMutableArray *array = [NSMutableArray arrayWithArray:self];

    [array removeObjectsAtIndexes:indexSet];

    return [NSArray arrayWithArray:array];
}


- (NSArray *)arrayByRemovingObjectAtIndex:(NSUInteger)index
{
    NSMutableArray *array = [NSMutableArray arrayWithArray:self];

    [array removeObjectAtIndex:index];

    return [NSArray arrayWithArray:array];
}


- (NSArray *)arrayByReplacingObject:(id)anObject withObject:(id)newObject
{
    NSMutableArray *mut = self.mutableObject;

    mut[[mut indexOfObject:anObject]] = newObject;

    return mut.immutableObject;
}

- (id)slicingObjectAtIndex:(NSInteger)index
{
    if (index < 0)
        return self[(NSUInteger)((NSInteger)self.count + index)];
    else
        return self[(NSUInteger)index];
}

- (id)safeSlicingObjectAtIndex:(NSInteger)index
{
    if (index < 0)
        return [self safeObjectAtIndex:(NSUInteger)((NSInteger)self.count + index)];
    else
        return [self safeObjectAtIndex:(NSUInteger)index];
}



- (id)safeObjectAtIndex:(NSUInteger)index
{
    if (self.count > index)
        return self[index];
    else
        return nil;
}


- (BOOL)containsDictionaryWithKey:(NSString *)key equalTo:(NSString *)value
{
    for (NSDictionary *dict in self)
    {
        NSObject *object = [dict valueForKey:key];
        if ([object isEqual:value])
            return TRUE;
    }

    return FALSE;
}


- (NSArray *)sortedArrayByKey:(NSString *)key
{
    return [self sortedArrayByKey:key ascending:YES];
}

- (NSArray *)sortedArrayByKey:(NSString *)key insensitive:(BOOL)insensitive
{
    if (!insensitive)
        return [self sortedArrayByKey:key ascending:YES];
    
    NSSortDescriptor *sd = [[NSSortDescriptor alloc] initWithKey:key ascending:YES selector:@selector(caseInsensitiveCompare:)];

    return [self sortedArrayUsingDescriptors:@[sd]];
    
}

- (NSArray *)sortedArrayByKey:(NSString *)key ascending:(BOOL)ascending
{
    NSSortDescriptor *sd = [[NSSortDescriptor alloc] initWithKey:key ascending:ascending];

    return [self sortedArrayUsingDescriptors:@[sd]];
}


- (NSArray *)subarrayFromIndex:(NSUInteger)location
{
    return [self subarrayWithRange:NSMakeRange(location, self.count-location)];
}

- (NSArray *)subarrayToIndex:(NSUInteger)location
{
    return [self subarrayWithRange:NSMakeRange(0, location)];
}

- (NSArray *)slicingSubarrayToIndex:(NSInteger)location
{
    if (location < 0)
    {
        NSInteger max = (NSInteger)self.count + location;
        return [self subarrayToIndex:(NSUInteger)max];
    }
    else
        return [self subarrayToIndex:(NSUInteger)location];
}

- (NSArray *)slicingSubarrayFromIndex:(NSInteger)location
{
    if (location < 0)
    {
        NSInteger max = (NSInteger)self.count + location;
        return [self subarrayFromIndex:(NSUInteger)max];
    }
    else
        return [self subarrayFromIndex:(NSUInteger)location];
}


- (NSMutableArray *)mutableObject
{
    return [NSMutableArray arrayWithArray:self];
}


- (BOOL)empty
{
    return self.count == 0;
}


- (NSArray *)mapped:(ObjectInOutBlock)block
{
    NSMutableArray *resultArray = [NSMutableArray new];

    for (id object in self)
    {
        id result = block(object);
        if (result)
            [resultArray addObject:result];
    }

    return [NSArray arrayWithArray:resultArray];
}


- (NSInteger)reduce:(ObjectInIntOutBlock)block
{
    NSInteger value = 0;

    for (id object in self)
        value += block(object);

    return value;
}


- (NSArray *)filtered:(BOOL (^)(id input))block
{
    NSMutableArray *resultArray = [NSMutableArray new];

    for (id object in self)
        if (block(object))
            [resultArray addObject:object];

    return [NSArray arrayWithArray:resultArray];
}

- (void)apply:(ObjectInBlock)block                                // similar = enumerateObjectsUsingBlock:
{
    for (id object in self)
        block(object);
}

- (NSString *)joined:(NSString *)sep                            // shortcut = componentsJoinedByString:
{
    return [self componentsJoinedByString:sep];
}

- (NSString *)joinedWithSpaces
{
    return [self componentsJoinedByString:@" "];
}

- (NSString *)joinedWithNewlines
{
    return [self componentsJoinedByString:@"\n"];
}

- (NSString *)joinedWithDots
{
    return [self componentsJoinedByString:@"."];
}

- (NSString *)joinedWithCommas
{
    return [self componentsJoinedByString:@","];
}

- (NSString *)joinedWithCommasAndSpaces
{
    return [self componentsJoinedByString:@", "];
}

- (NSArray *)filteredUsingPredicateString:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    NSPredicate *pred = [NSPredicate predicateWithFormat:format arguments:args];
    va_end(args);

    return [self filteredArrayUsingPredicate:pred];
}


#if CL_TARGET_CLI || CL_TARGET_OSX
- (NSString *)runAsTask
{
    return [self runAsTaskWithTerminationStatus:NULL];
}


- (NSString *)runAsTaskWithTerminationStatus:(NSInteger *)terminationStatus
{
    __block dispatch_semaphore_t readabilitySemaphore = dispatch_semaphore_create(0);

    NSMutableString *jobOutput = makeMutableString();
    NSTask *task = [[NSTask alloc] init];
    NSPipe *standardOutput = NSPipe.pipe;
    NSPipe *standardError = NSPipe.pipe;

    task.launchPath = self[0];
    task.standardOutput = standardOutput;
    task.standardError = standardError;
    task.arguments = [self subarrayWithRange:NSMakeRange(1, self.count-1)];
    
    if ([task.arguments reduce:^int(NSString *input) { return (int)input.length; }] > 200000)
        cc_log_error(@"Error: task argument size approaching or above limit, spawn will fail");
    
    NSFileHandle *standardOutputHandle = standardOutput.fileHandleForReading;
    [standardOutputHandle setReadabilityHandler:^(NSFileHandle *file)
    { // DO NOT use -availableData in these handlers. => https://stackoverflow.com/questions/49184623/nstask-race-condition-with-readabilityhandler-block/49291298#49291298
          NSData *newData = [file readDataOfLength:NSUIntegerMax];
          if (newData.length == 0)
          {   // end of data signal is an empty data object.
              file.readabilityHandler = nil;
              dispatch_semaphore_signal(readabilitySemaphore);
          }
          else
          {
              @synchronized (jobOutput)
              {
                  NSString *string = newData.string;
                  if (string)
                      [jobOutput appendString:string];
              }
          }
    }];
    NSFileHandle *standardErrorHandle = standardError.fileHandleForReading;
    [standardErrorHandle setReadabilityHandler:^(NSFileHandle *file)
    { // DO NOT use -availableData in these handlers. => https://stackoverflow.com/questions/49184623/nstask-race-condition-with-readabilityhandler-block/49291298#49291298
          NSData *newData = [file readDataOfLength:NSUIntegerMax];
          if (newData.length == 0)
          {   // end of data signal is an empty data object.
              file.readabilityHandler = nil;
              dispatch_semaphore_signal(readabilitySemaphore);
          }
          else
          {
              @synchronized (jobOutput)
              {
                  NSString *string = newData.string;
                  if (string)
                      [jobOutput appendString:string];
              }
          }
    }];
    
    
    @try
    {
        [task launch];
    }
    @catch (NSException *e)
    {
        cc_log_error(@"Error: got exception %@ while trying to perform task %@", e.description, [self joined:@" "]);
        return nil;
    }


    dispatch_semaphore_wait(readabilitySemaphore, DISPATCH_TIME_FOREVER);
    dispatch_semaphore_wait(readabilitySemaphore, DISPATCH_TIME_FOREVER);
    readabilitySemaphore = nil;

    [standardOutputHandle closeFile];
    [standardErrorHandle closeFile];
    
    
    if (terminationStatus)
    {
        if (task.isRunning)
        {
            cc_log(@"Info: sleeping in order to be able to get terminationStatus for: %@", [self joined:@" "]);
            [NSThread sleepForTimeInterval:0.05];
        }

        if (task.isRunning)
            cc_log_error(@"Error: task is still running, avoiding to try to obtain terminationStatus for: %@", [self joined:@" "]);
        else
        {
            @try
            {
                (*terminationStatus) = task.terminationStatus;
            }
            @catch (NSException *e)
            {
                cc_log_error(@"Error: got exception '%@' while trying to get terminationStatus for: %@", e.description, [self joined:@" "]);
            }
        }
    }
    
    return jobOutput;
}

- (NSString *)runAsTaskWithProgressBlock:(StringInBlock)progressBlock
{
    return [self runAsTaskWithProgressBlock:progressBlock terminationStatus:NULL];
}

- (NSString *)runAsTaskWithProgressBlock:(StringInBlock)progressBlock terminationStatus:(NSInteger *)terminationStatus
{
    __block dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    NSMutableString *jobOutput = makeMutableString();
    
    NSTask *task = [[NSTask alloc] init];
    NSPipe *taskPipe = [NSPipe pipe];
    task.launchPath = self[0];
    task.standardOutput = taskPipe;
    task.standardError = taskPipe;
    task.arguments = [self subarrayWithRange:NSMakeRange(1, self.count-1)];

    NSFileHandle *fileHandle = taskPipe.fileHandleForReading;
    
    [fileHandle setReadabilityHandler:^(NSFileHandle *file)
    { // despite allegations that using -availableData in these handlers us bad we cannot avoid it as the alternative blocks until the task exits (https://stackoverflow.com/questions/49184623/nstask-race-condition-with-readabilityhandler-block/49291298#49291298)
        NSData *data = file.availableData;
        NSString *string = data.string;
        
        if (string)
            [jobOutput appendString:string];

        progressBlock(string);
    }];
  
    
    [task setTerminationHandler:^(NSTask *t)
    {
        fileHandle.readabilityHandler = nil;

        assert(sema);
        dispatch_semaphore_signal(sema);
    }];

    
    @try
    {
        [task launch];
    }
    @catch (NSException *e)
    {
        cc_log_error(@"Error: got exception %@ while trying to perform task %@", e.description, [self joined:@" "]);
        return nil;
    }

    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    
    sema = NULL;
 
    
    if (terminationStatus)
    {
        if (task.isRunning)
        {
            cc_log(@"Info: sleeping in order to be able to get terminationStatus for: %@", [self joined:@" "]);
            [NSThread sleepForTimeInterval:0.05];
        }

        if (task.isRunning)
            cc_log_error(@"Error: task is still running, avoiding to try to obtain terminationStatus %@", [self joined:@" "]);
        else
        {
            @try
            {
                (*terminationStatus) = task.terminationStatus;
            }
            @catch (NSException *e)
            {
                cc_log_error(@"Error: got exception '%@' while trying to get terminationStatus for: %@", e.description, [self joined:@" "]);
            }
        }
    }
    
    [fileHandle closeFile];

    
    return jobOutput;
}
#endif
@end
