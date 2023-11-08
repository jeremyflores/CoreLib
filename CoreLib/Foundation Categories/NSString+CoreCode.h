//
//  NSString+CoreCode.h
//  MacUpdater
//
//  Created by Carterhaugh LLC on 8/15/23.
//  Copyright © 2023 CoreCode Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CLTarget.h"
#import "CLTypes.h"
#import "CLUIImport.h"

@interface NSString (CoreCode)

// filesystem support
@property (readonly, nonatomic) NSArray <NSString *> *directoryContents;
@property (readonly, nonatomic) NSArray <NSString *> *directoryContentsRecursive;
@property (readonly, nonatomic) NSArray <NSString *> *directoryContentsAbsolute;
@property (readonly, nonatomic) NSArray <NSString *> *directoryContentsRecursiveAbsolute;
@property (readonly, nonatomic) NSString *uniqueFile;
@property (readonly, nonatomic) BOOL fileExists;
#if CL_TARGET_OSX || CL_TARGET_CLI
@property (readonly, nonatomic) BOOL fileIsRestricted;
@property (readonly, nonatomic) BOOL fileIsAlias; // this also returns one for symlinks - on macOS 12
@property (readonly, nonatomic) BOOL fileIsSymlink;
@property (readonly, nonatomic) BOOL fileHasSymlinkInPath;
@property (readonly, nonatomic) NSString *fileAliasTarget;
#endif
@property (readonly, nonatomic) unsigned long long fileSize;
@property (readonly, nonatomic) unsigned long long directorySize;
@property (readonly, nonatomic) BOOL isWriteablePath;
@property (readonly, nonatomic) NSString *stringByResolvingSymlinksInPathFixed;
@property (readonly, nonatomic) NSString *reverseString;



@property (readonly, nonatomic) NSRange fullRange;
@property (readonly, nonatomic) NSString *literalString;

@property (readonly, nonatomic) NSArray <NSString *> *pathsMatchingPattern; // can resolve /path/**/file.txt to all existing matches on the file system but only a single /**/ is allowed


// path string to url
@property (readonly, nonatomic) NSURL *fileURL;
@property (readonly, nonatomic) NSURL *URL;
// url string download
@property (readonly, nonatomic) NSData *download;
@property (readonly, nonatomic) NSString *downloadWithCurl;
// path string filedata
@property (unsafe_unretained, nonatomic) NSData *contents;



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

#if CL_TARGET_OSX
@property (readonly, nonatomic) NSImage *namedImage;
#elif CL_TARGET_IOS
@property (readonly, nonatomic) UIImage *namedImage;
#endif

// string things
@property (readonly, nonatomic) NSArray <NSString *> *lines;
@property (readonly, nonatomic) NSArray <NSString *> *words;
@property (readonly, nonatomic) unichar firstChar;
@property (readonly, nonatomic) unichar lastChar;
@property (readonly, nonatomic) NSUInteger lengthFixed;     // string length that doesn't fuck up for emoji

@property (readonly, nonatomic) NSString *expanded;                        // shortcut = stringByExpandingTildeInPath
@property (readonly, nonatomic) NSString *expandedWithCareForSudo;      // this will be able to expand tildes even if a CLI tools is called with sudo
@property (readonly, nonatomic) NSString *strippedOfNewlines;               // deletes from interior of string too, in contrast to TRIMMING which deletes only from front and back ... shortcut for stringByDeletingCharactersInSet:newlineCharacterSet
@property (readonly, nonatomic) NSString *strippedOfWhitespace;             // deletes from interior of string too, in contrast to TRIMMING which deletes only from front and back ... shortcut for stringByDeletingCharactersInSet:whitespaceCharacterSet
@property (readonly, nonatomic) NSString *strippedOfWhitespaceAndNewlines;
@property (readonly, nonatomic) NSString *trimmedOfWhitespace;
@property (readonly, nonatomic) NSString *trimmedOfWhitespaceAndNewlines;
@property (readonly, nonatomic) NSString *unescaped;
@property (readonly, nonatomic) NSString *escaped; // URL escaping
@property (readonly, nonatomic) NSString *encoded; // total encoding, wont work with OPEN anymore as it encodes everything except numbers and letters, useful for single CGI params
@property (readonly, nonatomic) NSString *escapedForXML; // just escapes <>'"& for HTML/XML contents
@property (readonly, nonatomic) NSString *escapedForHTML; // just escapes umlauts for HTML/XML


@property (readonly, nonatomic) NSMutableString *mutableObject;

@property (readonly, nonatomic) NSString *rot13;
#ifdef USE_SECURITY
@property (readonly, nonatomic) NSString *SHA1;     // 20 byte - 160 bit
@property (readonly, nonatomic) NSString *SHA256;   // 32 byte - 256 bit
#endif
@property (readonly, nonatomic) NSString *language;


@property (readonly, nonatomic) NSString *titlecaseString;
@property (readonly, nonatomic) NSString *propercaseString;
@property (readonly, nonatomic) BOOL isIntegerNumber;
@property (readonly, nonatomic) BOOL isIntegerNumberOnly;
@property (readonly, nonatomic) BOOL isFloatNumber;
@property (readonly, nonatomic) BOOL isValidEmail;
@property (readonly, nonatomic) BOOL isValidEmails;
@property (readonly, nonatomic) BOOL isNumber;

@property (readonly, nonatomic) NSData *data;    // data of string contents
@property (readonly, nonatomic) NSData *dataFromHexString;
@property (readonly, nonatomic) NSData *dataFromBase64String;

@property (readonly, nonatomic) NSCharacterSet *characterSet;


- (unichar)slicingCharacterAtIndex:(NSInteger)ind;
- (unichar)safeSlicingCharacterAtIndex:(NSInteger)ind;
- (unichar)safeCharacterAtIndex:(NSUInteger)ind;

- (NSArray <NSArray <NSString *> *> *)parsedDSVWithDelimiter:(NSString *)delimiter;

- (NSString *)stringValue;

- (NSUInteger)count:(NSString *)str; // peviously called countOccurencesOfString
- (BOOL)contains:(NSString *)otherString insensitive:(BOOL)insensitive;         // similar: rangeOfString options != NSNotFound
- (BOOL)contains:(NSString *)otherString;                                       // similar: rangeOfString != NSNotFound
- (BOOL)containsRegexp:(NSString *)otherString;                                 // similar: rangeOfString options != NSNotFound
- (BOOL)hasAnyPrefix:(NSArray <NSString *>*)possiblePrefixes;
- (BOOL)hasAnySuffix:(NSArray <NSString *>*)possibleSuffixes;
- (BOOL)containsAny:(NSArray <NSString *>*)otherStrings;
- (BOOL)containsAny:(NSArray <NSString *>*)otherStrings insensitive:(BOOL)insensitive;
- (BOOL)containsAll:(NSArray <NSString *>*)otherStrings;
- (BOOL)equalsAny:(NSArray <NSString *>*)otherStrings;
- (NSString *)stringByReplacingMultipleStrings:(NSDictionary <NSString *, NSString *>*)replacements;
- (NSString *)paddedWithSpaces:(NSUInteger)minimumLengh; // pads with spaces
- (NSString *)clamp:(NSUInteger)maximumLength;
- (NSString *)clampByteLength:(NSUInteger)maximumLength; // normal clamp clamps to number of chars. however with multi-byte chars, the upper bound for the number of bytes in UTF8 is (maximumLength * 4)
- (NSString *)tail:(NSUInteger)maximumLength;
- (NSString *)shortened:(NSUInteger)maximumLength; // so clamp gives you the beginning and cuts the end, tail cuts the beginning and gives you the end, but SHORTENED gives you "beginning…end" and cuts the middle
- (NSString *)shortenedLinewise:(NSUInteger)maximumLines; // same as above but linewise. problematic if lines are super long


// split a string at a splitter - return part before or after splitter - two variants, return either full string or null in case the seperator doesn't occur
- (NSString *)splitBeforeFull:(NSString *)sep;
- (NSString *)splitAfterFull:(NSString *)sep;
- (NSString *)splitBeforeNull:(NSString *)sep;
- (NSString *)splitAfterNull:(NSString *)sep;

- (NSString *)between:(NSString *)sep1 and:(NSString *)sep2; // returns string part between 1 and 2, nil if not possible

- (NSString *)commonSuffixWithString:(NSString *)str options:(NSStringCompareOptions)mask; // complementary to the commonPrefix... method in Foundation


#if CL_TARGET_OSX
- (NSArray <NSString *> *)misspelledWords:(NSArray <NSString *> *)wordsToIgnore;
- (NSAttributedString *)attributedStringWithColor:(NSColor *)color;
- (NSAttributedString *)attributedStringWithHyperlink:(NSURL *)url;
- (NSAttributedString *)attributedStringWithFont:(NSFont *)font;
#endif

- (NSString *)capitalizedStringWithUppercaseWords:(NSArray <NSString *> *)uppercaseWords;
- (NSString *)titlecaseStringWithLowercaseWords:(NSArray <NSString *> *)lowercaseWords andUppercaseWords:(NSArray <NSString *> *)uppercaseWords;

- (NSString *)stringByTrimmingLeadingCharactersInSet:(NSCharacterSet *)characterSet;
- (NSString *)stringByTrimmingTrailingCharactersInSet:(NSCharacterSet *)characterSet;
- (NSString *)stringByDeletingCharactersInSet:(NSCharacterSet *)characterSet;

- (NSString *)stringByDeduplicatingSuccessiveIdenticalLines;


#if CL_TARGET_OSX
- (CGSize)sizeUsingFont:(NSFont *)font maxWidth:(CGFloat)maxWidth;
#endif

#if CL_TARGET_OSX || CL_TARGET_CLI
// FSEvents directory observing
- (NSValue *)startObserving:(ObjectInBlock)block withFileLevelEvents:(BOOL)fileLevelEvents; // the block is guaranteed to be executed in the main thread
- (void)stopObserving:(NSValue *)token;
#endif

- (NSString *)removed:(NSString *)stringToRemove;                       // similar: stringByReplacingOccurrencesOfString:stringToRemove withString:@""];
- (NSString *)removedSuffix:(NSString *)stringToRemove;
- (NSString *)removedPrefix:(NSString *)stringToRemove;

- (NSString *)slicingSubstringFromIndex:(NSInteger)index;  // get string with chars cut-off: index should be negative and tell how many chars to include from the end: -1 is just the last char
- (NSString *)slicingSubstringToIndex:(NSInteger)index;  // get string with chars cut-off: index should be negative and tell how many chars to remove from the end: -1 removes one char from the end
- (NSString *)substringWithRegexp:(NSString *)otherString;


// forwards for less typing - equivalent to AppKit methods and only shorter
- (NSString *)replaced:(NSString *)str1 with:(NSString *)str2;            // shortcut = stringByReplacingOccurencesOfString:withString:
- (NSArray <NSString *> *)split:(NSString *)sep;                        // shortcut = componentsSeparatedByString:
- (NSString *)appended:(NSString *)str;                                 // shortcut = stringByAppendingString

- (NSString *)stringByAppendingPathComponents:(NSArray<NSString *> *)components;

@end
