//
//  Foundation+CoreCode.h
//  CoreLib
//
//  Created by CoreCode on 15.03.12.
/*	Copyright (c) 2012 - 2014 CoreCode
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */


#include "CoreLib.h"



@interface NSArray (CoreCode)

@property (readonly, nonatomic) NSArray *reverseArray;
@property (readonly, nonatomic) NSMutableArray *mutableObject;
@property (readonly, nonatomic) BOOL empty;
@property (readonly, nonatomic) NSData *JSONData;
@property (readonly, nonatomic) NSString *string;
@property (readonly, nonatomic) NSString *path;

- (NSArray *)arrayByAddingNewObject:(id)anObject;			// adds the object only if it is not identical (contentwise) to existing entry
- (NSArray *)arrayByRemovingObjectIdenticalTo:(id)anObject;
- (NSArray *)arrayByRemovingObjectsIdenticalTo:(NSArray *)objects;
- (NSArray *)arrayByRemovingObjectAtIndex:(NSUInteger)index;
- (NSArray *)arrayByRemovingObjectsAtIndexes:(NSIndexSet *)indexSet;
- (NSArray *)arrayByReplacingObject:(id)anObject withObject:(id)newObject;
- (id)safeObjectAtIndex:(NSUInteger)index;
- (NSString *)safeStringAtIndex:(NSUInteger)index;
- (BOOL)containsDictionaryWithKey:(NSString *)key equalTo:(NSString *)value;
- (NSArray *)sortedArrayByKey:(NSString *)key;
- (NSArray *)sortedArrayByKey:(NSString *)key ascending:(BOOL)ascending;
- (BOOL)contains:(id)object;

#if defined(TARGET_OS_MAC) && TARGET_OS_MAC && !TARGET_OS_IPHONE
- (NSString *)runAsTask;
- (NSString *)runAsTaskWithTerminationStatus:(NSInteger *)terminationStatus;
#endif

- (NSArray *)mapped:(ObjectInOutBlock)block;
- (NSArray *)filtered:(ObjectInIntOutBlock)block;
- (NSArray *)filteredUsingPredicateString:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);
- (NSInteger)collect:(ObjectInIntOutBlock)block;

// versions similar to cocoa methods
- (void)apply:(ObjectInBlock)block;								// enumerateObjectsUsingBlock:

// forwards for less typing
- (NSString *)joined:(NSString *)sep;							// componentsJoinedByString:

@property (readonly, nonatomic) NSSet *set;


@end



@interface NSMutableArray (CoreCode)

@property (readonly, nonatomic) NSArray *immutableObject;

- (void)addNewObject:(id)anObject;
- (void)addObjectSafely:(id)anObject;
- (void)map:(ObjectInOutBlock)block;
- (void)filter:(ObjectInIntOutBlock)block;
- (void)filterUsingPredicateString:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);
- (void)removeFirstObject;

@end





@interface NSData (CoreCode)

@property (readonly, nonatomic) NSMutableData *mutableObject;
@property (readonly, nonatomic) NSString *string;
@property (readonly, nonatomic) NSString *hexString;
@property (readonly, nonatomic) NSDictionary *JSONDictionary;
@property (readonly, nonatomic) NSArray *JSONArray;

@end



@interface NSDate (CoreCode)

// date format strings:   dd.MM.yyyy HH:mm:ss
+ (NSDate *)dateWithString:(NSString *)dateString andFormat:(NSString *)dateFormat andLocaleIdentifier:(NSString *)localeIdentifier;
+ (NSDate *)dateWithString:(NSString *)dateString andFormat:(NSString *)dateFormat;
+ (NSDate *)dateWithPreprocessorDate:(const char *)preprocessorDateString;
- (NSString *)stringUsingFormat:(NSString *)dateFormat;
- (NSString *)stringUsingDateStyle:(NSDateFormatterStyle)dateStyle andTimeStyle:(NSDateFormatterStyle)timeStyle;

@end



@interface NSDateFormatter (CoreCode)

+ (NSString *)formattedTimeFromTimeInterval:(NSTimeInterval)timeInterval;

@end



@interface NSDictionary (CoreCode)

@property (readonly, nonatomic) NSData *JSONData;
@property (readonly, nonatomic) NSMutableDictionary *mutableObject;
- (NSDictionary *)dictionaryByAddingValue:(id)value forKey:(NSString *)key;

@end


@interface NSMutableDictionary (CoreCode)

@property (readonly, nonatomic) NSDictionary *immutableObject;

@end



@interface NSFileHandle (CoreCode)

- (float)readFloat;
- (int)readInt;

@end



@interface NSLocale (CoreCode)

+ (NSArray *)preferredLanguages3Letter;

@end




@interface NSObject (CoreCode)

- (id)associatedValueForKey:(NSString *)key;
- (void)setAssociatedValue:(id)value forKey:(NSString *)key;
@property (retain, nonatomic) id associatedValue;

@end




@interface NSString (CoreCode)

// filesystem support
@property (readonly, nonatomic) NSStringArray *dirContents;
@property (readonly, nonatomic) NSStringArray *dirContentsRecursive;
@property (readonly, nonatomic) NSString *uniqueFile;
@property (readonly, nonatomic) BOOL fileExists;
@property (readonly, nonatomic) unsigned long long fileSize;
@property (readonly, nonatomic) BOOL isWriteablePath;

// path string to url
@property (readonly, nonatomic) NSURL *fileURL;
@property (readonly, nonatomic) NSURL *URL;
// url string download
@property (readonly, nonatomic) NSData *download;
// path string filedata
@property (readonly, nonatomic) NSData *contents;


// NSUserDefaults support
@property (copy, nonatomic) id defaultObject;
@property (copy, nonatomic) NSString *defaultString;
@property (copy, nonatomic) NSArray *defaultArray;
@property (copy, nonatomic) NSDictionary *defaultDict;
@property (copy, nonatomic) NSURL *defaultURL;
@property (assign, nonatomic) NSInteger defaultInt;
@property (assign, nonatomic) float defaultFloat;

@property (readonly, nonatomic) NSString *localized;

//  bundle contents to path
@property (readonly, nonatomic) NSString *resourcePath;
@property (readonly, nonatomic) NSURL *resourceURL;
#if defined(TARGET_OS_MAC) && TARGET_OS_MAC && !TARGET_OS_IPHONE
@property (readonly, nonatomic) NSImage *namedImage;
#else
@property (readonly, nonatomic) UIImage *namedImage;
#endif

// string things
@property (readonly, nonatomic) NSStringArray *lines;
@property (readonly, nonatomic) NSStringArray *words;
@property (readonly, nonatomic) NSString *trimmed;
@property (readonly, nonatomic) NSString *expanded;
@property (readonly, nonatomic) NSString *escaped; // URL escaping
@property (readonly, nonatomic) NSString *encoded; // total encoding, wont work with OPEN anymore as it encodes the slashes

@property (readonly, nonatomic) NSMutableString *mutableObject;
#ifdef USE_SECURITY
@property (readonly, nonatomic) NSString *SHA1;
#endif


@property (readonly, nonatomic) NSData *dataFromHexString;

@property (readonly, nonatomic) NSString *titlecaseString;
@property (readonly, nonatomic) NSString *propercaseString;


- (NSString *)stringValue;

- (NSUInteger)countOccurencesOfString:(NSString *)str;
- (BOOL)contains:(NSString *)otherString insensitive:(BOOL)insensitive;
- (BOOL)contains:(NSString *)otherString;
- (BOOL)containsAny:(NSArray *)otherStrings;
- (NSString *)stringByReplacingMultipleStrings:(NSDictionary *)replacements;
- (NSString *)clamp:(NSUInteger)maximumLength;
//- (NSString *)arg:(id)arg, ...;


// forwards for less typing
- (NSString *)replaced:(NSString *)str1 with:(NSString *)str2;		// stringByReplacingOccurencesOfString:withString:
- (NSStringArray *)split:(NSString *)sep;								// componentsSeparatedByString:

@end


@interface NSMutableString (CoreCode)

@property (readonly, nonatomic) NSString *immutableObject;

@end



@interface NSURL (CoreCode)

- (NSURL *)add:(NSString *)component;
- (void)open;

@property (readonly, nonatomic) NSString *path;
@property (readonly, nonatomic) NSStringArray *dirContents;
@property (readonly, nonatomic) NSStringArray *dirContentsRecursive;
@property (readonly, nonatomic) NSURL *uniqueFile;
@property (readonly, nonatomic) BOOL fileExists;
@property (readonly, nonatomic) unsigned long long fileSize;
@property (readonly, nonatomic) NSURLRequest *request;
@property (readonly, nonatomic) BOOL isWriteablePath;
// url string download
@property (readonly, nonatomic) NSData *download;
// path string filedata
@property (readonly, nonatomic) NSData *contents;


@end



