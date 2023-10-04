//
//  NSString+CoreCode.m
//  MacUpdater
//
//  Created by Carterhaugh LLC on 8/15/23.
//  Copyright © 2023 CoreCode Limited. All rights reserved.
//

#import "NSString+CoreCode.h"

#import "CLSecurityImport.h"

#import "CLConstantKey.h"
#import "CLDispatch.h"
#import "CLGlobals.h"
#import "CLLogging.h"
#import "CLMakers.h"
#import "CLSwifty.h"
#import "CLTarget.h"

#import "NSMutableCharacterSet+CoreCode.h"
#import "NSArray+CoreCode.h"
#import "NSObject+CoreCode.h"
#import "NSURL+CoreCode.h"

@implementation NSString (CoreCode)

@dynamic words, lines, strippedOfWhitespace, strippedOfNewlines, trimmedOfWhitespace, trimmedOfWhitespaceAndNewlines, URL, fileURL, download, downloadWithCurl, resourceURL, resourcePath, localized, defaultObject, defaultString, defaultInt, defaultFloat, defaultURL, directoryContents, directoryContentsRecursive, directoryContentsAbsolute, directoryContentsRecursiveAbsolute, fileExists, uniqueFile, expanded, defaultArray, defaultDict, isWriteablePath, fileSize, directorySize, contents, dataFromHexString, dataFromBase64String, unescaped, escaped, isIntegerNumber, isIntegerNumberOnly, isFloatNumber, data, firstChar, lastChar, fullRange, stringByResolvingSymlinksInPathFixed, literalString, isNumber, rot13, characterSet, lengthFixed, reverseString, pathsMatchingPattern;

#if CL_TARGET_IOS || CL_TARGET_OSX
@dynamic namedImage;
#endif

#if CL_TARGET_OSX
@dynamic fileIsAlias, fileAliasTarget, fileIsSymlink, fileIsRestricted, fileHasSymlinkInPath;
#endif

#ifdef USE_SECURITY
@dynamic SHA1, SHA256;
#endif

- (NSArray <NSString *> *)pathsMatchingPattern
{
    assert([self count:@"**"] == 1);
    NSString *prefix = [self splitBeforeNull:@"**"];
    NSString *suffix = [self splitAfterNull:@"**"];
    NSMutableArray *results = makeMutableArray();
    NSDirectoryEnumerator *filesEnumerator = [NSFileManager.defaultManager enumeratorAtPath:prefix];

    NSString *file;
    while ((file = filesEnumerator.nextObject))
    {
        if ([file hasSuffix:suffix])
            [results addObject:[prefix stringByAppendingPathComponent:file]];
    }
    if (results.count)
        return results;
    else
        return nil;
}

- (NSUInteger)lengthFixed
{
    NSUInteger realLength = [self lengthOfBytesUsingEncoding:NSUTF32StringEncoding] / 4;
    return realLength;
}

- (NSCharacterSet *)characterSet
{
    NSCharacterSet *cs = [NSCharacterSet characterSetWithCharactersInString:self];
    assert(cs);
    return cs;
}

- (NSString *)commonSuffixWithString:(NSString *)str options:(NSStringCompareOptions)mask
{
    NSString *reversedSelf = self.reverseString;
    NSString *reversedOther = str.reverseString;
    NSString *common = [reversedSelf commonPrefixWithString:reversedOther options:mask];
    
    return common.reverseString;
}

- (NSString *)reverseString
{
    NSUInteger length = [self length];
    if (length < 2) {
        return self;
    } // thanks @ https://stackoverflow.com/questions/6720191/reverse-nsstring-text

    NSStringEncoding encoding = NSHostByteOrder() == NS_BigEndian ? NSUTF32BigEndianStringEncoding : NSUTF32LittleEndianStringEncoding;
    NSUInteger utf32ByteCount = [self lengthOfBytesUsingEncoding:encoding];
    uint32_t *characters = malloc(utf32ByteCount);
    if (!characters) {
        return nil;
    }

    [self getBytes:characters maxLength:utf32ByteCount usedLength:NULL encoding:encoding options:0 range:NSMakeRange(0, length) remainingRange:NULL];

    NSUInteger utf32Length = utf32ByteCount / sizeof(uint32_t);
    NSUInteger halfwayPoint = utf32Length / 2;
    for (NSUInteger i = 0; i < halfwayPoint; ++i) {
        uint32_t character = characters[utf32Length - i - 1];
        characters[utf32Length - i - 1] = characters[i];
        characters[i] = character;
    }

    return [[NSString alloc] initWithBytesNoCopy:characters length:utf32ByteCount encoding:encoding freeWhenDone:YES];
}

- (NSString *)rot13
{
    const char *cstring = [self cStringUsingEncoding:NSASCIIStringEncoding];

    if (!cstring)
    {
        cc_log_error(@"Error: non-ascii string problem");
        return nil;
    }

    char *newcstring = malloc(self.length+1);
    
    
    NSUInteger x;
    for(x = 0; x < self.length; x++)
    {
        unsigned int aCharacter = (unsigned int)cstring[x];
        
        if (0x40 < aCharacter && aCharacter < 0x5B) // A - Z
            newcstring[x] = (((aCharacter - 0x41) + 0x0D) % 0x1A) + 0x41;
        else if (0x60 < aCharacter && aCharacter < 0x7B) // a-z
            newcstring[x] = (((aCharacter - 0x61) + 0x0D) % 0x1A) + 0x61;
        else  // Not an alpha character
            newcstring[x] = (char)aCharacter;
    }
    
    newcstring[x] = '\0';
    
    NSString *rotString = @(newcstring);
    free(newcstring);
    return rotString;
}

#if CL_TARGET_OSX
- (NSArray <NSString *> *)misspelledWords:(NSArray <NSString *> *)wordsToIgnore
{
    NSUInteger startPosition = 0;
    let foundOffenders = makeMutableArray();
    
    while (startPosition != NSNotFound)
    {
        let range = [NSSpellChecker.sharedSpellChecker checkSpellingOfString:self startingAt:(NSInteger)startPosition language:nil wrap:NO inSpellDocumentWithTag:0 wordCount:NULL];
        
        if (range.location != NSNotFound)
        {
            let offendingWord = [self substringWithRange:range];
            if (![wordsToIgnore containsString:offendingWord insensitive:YES])
                [foundOffenders addObject:offendingWord];
        }
        startPosition = range.location + range.length;
    }
    return foundOffenders.count ? foundOffenders : nil;
}
#endif

#if CL_TARGET_OSX
- (NSImage *)namedImage
{
    NSImage *image = [NSImage imageNamed:self];

    if (!image)
        cc_log_error(@"Error: there is no named image with name: %@", self);

    return image;
}
#elif CL_TARGET_IOS
- (UIImage *)namedImage
{
    UIImage *image = [UIImage imageNamed:self];

    if (!image)
        cc_log_error(@"Error: there is no named image with name: %@", self);

    return image;
}
#endif

#if CL_TARGET_OSX

- (BOOL)fileIsRestricted
{
    struct stat info;
    lstat(self.UTF8String, &info);
    return (info.st_flags & SF_RESTRICTED) > 0;
}

- (BOOL)fileIsAlias
{
    NSURL *url = [NSURL fileURLWithPath:self];
    CFURLRef cfurl = (__bridge CFURLRef) url;
    CFBooleanRef aliasBool = kCFBooleanFalse;
    Boolean success = CFURLCopyResourcePropertyForKey(cfurl, kCFURLIsAliasFileKey, &aliasBool, NULL);
    Boolean alias = CFBooleanGetValue(aliasBool);

    return alias && success;
}

- (BOOL)fileIsSymlink
{
    NSURL *url = [NSURL fileURLWithPath:self];
    CFURLRef cfurl = (__bridge CFURLRef) url;
    CFBooleanRef aliasBool = kCFBooleanFalse;
    Boolean success = CFURLCopyResourcePropertyForKey(cfurl, kCFURLIsSymbolicLinkKey, &aliasBool, NULL);
    Boolean alias = CFBooleanGetValue(aliasBool);
    
    return alias && success;
}

- (BOOL)fileHasSymlinkInPath
{
    NSString *p = self;
    if ([p hasSuffix:@"/"])
        p = [p slicingSubstringToIndex:-1];
    NSString *pr = p.stringByResolvingSymlinksInPath;
    return ![pr isEqualToString:p];
}

- (NSString *)stringByResolvingSymlinksInPathFixed
{
    NSString *ret = self.stringByResolvingSymlinksInPath;


    for (NSString *exception in @[@"/etc/", @"/tmp/", @"/var/"])
    {
        if ([ret hasPrefix:exception])
        {
            NSString *fixed = [@"/private" stringByAppendingPathComponent:ret];

            return fixed;
        }
    }

    return ret;
}



- (NSString *)fileAliasTarget
{
    CFErrorRef *err = NULL;
    CFDataRef bookmark = CFURLCreateBookmarkDataFromFile(NULL, (__bridge CFURLRef)self.fileURL, err);
    if (bookmark == nil)
        return nil;
    CFURLRef url = CFURLCreateByResolvingBookmarkData (NULL, bookmark, kCFBookmarkResolutionWithoutUIMask, NULL, NULL, NULL, err);
    __autoreleasing NSURL *nurl = [(__bridge NSURL *)url copy];
    CFRelease(bookmark);
    CFRelease(url);

    return nurl.path;

}

- (CGSize)sizeUsingFont:(NSFont *)font maxWidth:(CGFloat)maxWidth
{
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithString:self];
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithContainerSize:NSMakeSize(maxWidth, DBL_MAX)];
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    [layoutManager addTextContainer:textContainer];
    [textStorage addLayoutManager:layoutManager];
    [textStorage beginEditing];
    [textStorage setAttributes:@{NSFontAttributeName: font} range:NSMakeRange(0, self.length)];
    [textStorage endEditing];

    (void) [layoutManager glyphRangeForTextContainer:textContainer];

    NSRect r = [layoutManager usedRectForTextContainer:textContainer];

    return r.size;
}
#endif

- (NSString *)literalString
{
    return makeString(@"@\"%@\"", self);
}

- (NSRange)fullRange
{
    return NSMakeRange(0, self.length);
}

- (unichar)safeCharacterAtIndex:(NSUInteger)ind
{
    if (ind < self.length)
        return [self characterAtIndex:ind];
    return 0;
}

- (unichar)slicingCharacterAtIndex:(NSInteger)ind
{
    if (ind < 0)
        return [self characterAtIndex:(NSUInteger)(((NSInteger)(self.length))+ind)];
    else
        return [self characterAtIndex:(NSUInteger)ind];
}

- (unichar)safeSlicingCharacterAtIndex:(NSInteger)ind
{
    if (ind < 0)
        return [self safeCharacterAtIndex:(NSUInteger)(((NSInteger)(self.length))+ind)];
    else
        return [self safeCharacterAtIndex:(NSUInteger)ind];
}

- (unichar)firstChar
{
    if (self.length)
        return [self characterAtIndex:0];
    return 0;
}

- (unichar)lastChar
{
    NSUInteger len = self.length;
    if (len)
        return [self characterAtIndex:len-1];
    return 0;
}

- (unsigned long long)fileSize
{
    assert(fileManager);
    NSDictionary *attr = [fileManager attributesOfItemAtPath:self error:NULL];
    if (!attr) return 0;
    NSNumber *fs = attr[NSFileSize];
    return fs.unsignedLongLongValue;
}

- (unsigned long long)directorySize
{
    return self.fileURL.directorySize;
}

- (BOOL)isIntegerNumber
{
    return [self rangeOfCharacterFromSet:NSCharacterSet.decimalDigitCharacterSet].location != NSNotFound;
}

- (BOOL)isNumber
{
    if (!self.length)
        return NO;

    if (self.isIntegerNumberOnly)
        return YES;

    return self.isFloatNumber;
}


- (BOOL)isIntegerNumberOnly
{
    return [self rangeOfCharacterFromSet:NSCharacterSet.decimalDigitCharacterSet.invertedSet].location == NSNotFound;
}

- (BOOL)isFloatNumber
{
    static NSCharacterSet *cs = nil;

    ONCE_PER_FUNCTION(^
    {
        NSMutableCharacterSet *tmp = [NSMutableCharacterSet characterSetWithCharactersInString:@",."];
        NSString *groupingSeparators = [[NSLocale currentLocale] objectForKey:NSLocaleGroupingSeparator];
        NSString *decimalSeparators = [[NSLocale currentLocale] objectForKey:NSLocaleDecimalSeparator];

        [tmp addCharactersInString:groupingSeparators];
        [tmp addCharactersInString:decimalSeparators];
        cs = tmp.immutableObject;
        assert(cs);
    })

    return ([self rangeOfCharacterFromSet:NSCharacterSet.decimalDigitCharacterSet].location != NSNotFound) && ([self rangeOfCharacterFromSet:cs].location != NSNotFound);
}

- (BOOL)isWriteablePath
{
    if (self.fileExists)
        return NO;

    if (![@"TEST" writeToFile:self atomically:YES encoding:NSUTF8StringEncoding error:NULL])
        return NO;

    assert(fileManager);
    [fileManager removeItemAtPath:self error:NULL];

    return YES;
}

- (BOOL)isValidEmails
{
    for (NSString *line in self.lines)
        if (!line.isValidEmail)
            return NO;
    
    return YES;
}

- (BOOL)isValidEmail
{
    if (self.length > 254)
        return NO;


    NSArray <NSString *> *portions = [self split:@"@"];

    if (portions.count != 2)
        return FALSE;

    NSString *local = portions[0];
    NSString *domain = portions[1];

    if (![domain contains:@"."])
        return FALSE;

    static NSCharacterSet *localValid = nil, *domainValid = nil;
    
    ONCE_PER_FUNCTION(^
    {
        localValid = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!#$%&'*+-/=?^_`{|}~."];
        domainValid = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-."];
        assert(localValid);
        assert(domainValid);
    })

    if ([local rangeOfCharacterFromSet:localValid.invertedSet options:(NSStringCompareOptions)0].location != NSNotFound)
        return NO;

    if ([domain rangeOfCharacterFromSet:domainValid.invertedSet options:(NSStringCompareOptions)0].location != NSNotFound)
        return NO;

    return YES;
}

- (NSArray <NSString *> *)directoryContents
{
    assert(fileManager);
    return [fileManager contentsOfDirectoryAtPath:self error:NULL];
}


- (NSArray <NSString *> *)directoryContentsRecursive
{
    assert(fileManager);
    NSDirectoryEnumerator *filesEnumerator = [fileManager enumeratorAtPath:self];
    NSMutableArray *results = makeMutableArray();
    NSString *file;
    while ((file = filesEnumerator.nextObject))
    {
        [results addObject:file];
    }
    return results;
}


- (NSArray <NSString *> *)directoryContentsAbsolute
{
    NSArray <NSString *> *c = self.directoryContents;
    return [c mapped:^NSString *(NSString *input) { return [self stringByAppendingPathComponent:input]; }];
}

- (NSArray <NSString *> *)directoryContentsRecursiveAbsolute
{
    assert(fileManager);
    NSDirectoryEnumerator *filesEnumerator = [fileManager enumeratorAtPath:self];
    NSMutableArray *results = makeMutableArray();
    NSString *file;
    while ((file = filesEnumerator.nextObject))
    {
        [results addObject:[self stringByAppendingPathComponent:file]];
    }
    return results;
}


- (NSString *)uniqueFile
{
    assert(fileManager);
    if (![fileManager fileExistsAtPath:self])
        return self;
    else
    {
        NSString *ext = self.pathExtension;
        NSString *namewithoutext = self.stringByDeletingPathExtension;
        int i = 0;

        while ([fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@-%i.%@", namewithoutext, i,ext]])
            i++;

        return [NSString stringWithFormat:@"%@-%i.%@", namewithoutext, i,ext];
    }
}

- (void)setContents:(NSData *)data
{
    NSError *err;
    
    if (!data)
        cc_log(@"Error: can not write null data to file %@", self);
    else if (![data writeToFile:self options:NSDataWritingAtomic error:&err])
        cc_log(@"Error: writing data to file has failed (file: %@ data: %lu error: %@)", self, (unsigned long)data.length, err.description);
}

- (NSData *)contents
{
    return [[NSData alloc] initWithContentsOfFile:self];
}

- (BOOL)fileExists
{
    assert(fileManager);
    return [fileManager fileExistsAtPath:self];
}

- (NSUInteger)count:(NSString *)str
{
    return [self componentsSeparatedByString:str].count - 1;
}

- (BOOL)hasAnyPrefix:(NSArray <NSString *>*)possiblePrefixes
{
    for (NSString *possiblePrefix in possiblePrefixes)
        if ([self hasPrefix:possiblePrefix])
            return YES;
    
    return NO;
}


- (BOOL)hasAnySuffix:(NSArray <NSString *>*)possibleSuffixes
{
    for (NSString *possibleSuffix in possibleSuffixes)
        if ([self hasSuffix:possibleSuffix])
            return YES;
    
    return NO;
}

- (BOOL)contains:(NSString *)otherString
{
    return ([self rangeOfString:otherString].location != NSNotFound);
}

- (BOOL)contains:(NSString *)otherString insensitive:(BOOL)insensitive
{
    return ([self rangeOfString:otherString options:insensitive ? NSCaseInsensitiveSearch : 0].location != NSNotFound);
}

- (BOOL)containsRegexp:(NSString *)otherString
{
    return ([self rangeOfString:otherString options:NSRegularExpressionSearch].location != NSNotFound);
}

- (NSString *)substringWithRegexp:(NSString *)otherString
{
    let regexpRange = [self rangeOfString:otherString options:NSRegularExpressionSearch];
    if (regexpRange.location == NSNotFound) return nil;
    return [self substringWithRange:regexpRange];
}


- (BOOL)containsAny:(NSArray <NSString *>*)otherStrings
{
    for (NSString *otherString in otherStrings)
        if ([self rangeOfString:otherString].location != NSNotFound)
            return YES;

    return NO;
}

- (BOOL)containsAny:(NSArray <NSString *>*)otherStrings insensitive:(BOOL)insensitive
{
    for (NSString *otherString in otherStrings)
        if ([self rangeOfString:otherString options:insensitive ? NSCaseInsensitiveSearch : 0].location != NSNotFound)
            return YES;
    
    return NO;
}

- (BOOL)containsAll:(NSArray <NSString *>*)otherStrings
{
    for (NSString *otherString in otherStrings)
        if ([self rangeOfString:otherString].location == NSNotFound)
            return NO;

    return YES;
}

- (BOOL)equalsAny:(NSArray <NSString *>*)otherStrings
{
    for (NSString *otherString in otherStrings)
        if ([self isEqualToString:otherString])
            return YES;
    
    return NO;
}

- (NSString *)localized
{
    NSString *localizedString = NSLocalizedString(self, nil);
#ifdef CUSTOM_LOCALIZED_STRING_REPLACEMENT
#define STRINGIZE(x) #x
#define STRINGIZE2(x) STRINGIZE(x)
#define LITERAL1 @ STRINGIZE2(CUSTOM_LOCALIZED_STRING_REPLACEMENT_FROM)
#define LITERAL2 @ STRINGIZE2(CUSTOM_LOCALIZED_STRING_REPLACEMENT_TO)

    localizedString = [localizedString replaced:LITERAL1
                                           with:LITERAL2];
#endif
    return localizedString;
}


- (NSString *)resourcePath
{
    assert(bundle);
    return [bundle pathForResource:self ofType:nil];
}

- (NSURL *)resourceURL
{
    assert(bundle);
    return [bundle URLForResource:self withExtension:nil];
}

- (NSURL *)URL
{
    return [NSURL URLWithString:self];
}

- (NSURL *)fileURL
{
    return [NSURL fileURLWithPath:self];
}

- (NSString *)expanded
{
    return self.stringByExpandingTildeInPath;
}

- (NSString *)expandedWithCareForSudo
{
    if ([self hasPrefix:@"~/"])
        return makeString(@"%@%@", NSProcessInfo.processInfo.environment[@"HOME"], [self substringFromIndex:1]);
    else
        return self;
}


- (NSArray <NSString *> *)words
{
    return [self componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (NSArray <NSString *> *)lines
{
    return [self componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
}


#if CL_TARGET_OSX
- (NSAttributedString *)attributedStringWithColor:(NSColor *)color
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self];
    
    [attributedString beginEditing];
    [attributedString addAttribute:NSForegroundColorAttributeName value:color range:self.fullRange];
    [attributedString endEditing];
    
    return attributedString;
}

- (NSAttributedString *)attributedStringWithHyperlink:(NSURL *)url
{
    NSString *urlstring = url.absoluteString;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self];

    [attributedString beginEditing];
    [attributedString addAttribute:NSLinkAttributeName value:urlstring range:self.fullRange];
    [attributedString addAttribute:NSForegroundColorAttributeName value:makeColor(0, 0, 1, 1) range:self.fullRange];
    [attributedString addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:self.fullRange];
    [attributedString endEditing];

    return attributedString;
}

- (NSAttributedString *)attributedStringWithFont:(NSFont *)font
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self];

    [attributedString beginEditing];
    [attributedString addAttribute:NSFontAttributeName value:font range:self.fullRange];
    [attributedString endEditing];

    return attributedString;
}
#endif

- (NSString *)strippedOfNewlines
{
    return [self stringByDeletingCharactersInSet:NSCharacterSet.newlineCharacterSet];
}

- (NSString *)strippedOfWhitespace
{
    return [self stringByDeletingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
}

- (NSString *)strippedOfWhitespaceAndNewlines
{
    return [self stringByDeletingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
}

- (NSString *)trimmedOfWhitespace
{
    return [self stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
}

- (NSString *)trimmedOfWhitespaceAndNewlines
{
    return [self stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
}

- (NSString *)paddedWithSpaces:(NSUInteger)minimumLength
{
    var tmpString = self;
    
    while (tmpString.length < minimumLength)
        tmpString = [tmpString appended:@" "];
    
    return tmpString;
}


- (NSString *)clamp:(NSUInteger)maximumLength
{
    return ((self.length <= maximumLength) ? self : [self substringToIndex:maximumLength]);
}

- (NSString *)clampByteLength:(NSUInteger)maximumLength
{
    NSString *clampedString = [self clamp:maximumLength];
    
    while ([clampedString lengthOfBytesUsingEncoding:NSUTF8StringEncoding] > maximumLength)
        clampedString = [clampedString slicingSubstringToIndex:-1];
    
    return clampedString;
}

- (NSString *)tail:(NSUInteger)maximumLength
{
    return ((self.length <= maximumLength) ? self : [self substringFromIndex:self.length - maximumLength]);
}

- (NSString *)shortened:(NSUInteger)maximumLength
{
    if (self.length <= maximumLength)
        return self;
    else
    {
        let halflength = (maximumLength - 1) / 2; // lets ignore rounding issues
        return makeString(@"%@…%@", [self clamp:halflength], [self tail:halflength]);
    }
}

- (NSString *)shortenedLinewise:(NSUInteger)maximumLines
{
    if (self.lines.count <= maximumLines)
        return self;
    else
    {
        long halflength = (maximumLines - 1) / 2; // lets ignore rounding issues
        return makeString(@"%@\n…\n%@", [self.lines subarrayToIndex:(uint)halflength].joinedWithNewlines, [self.lines slicingSubarrayFromIndex:-halflength].joinedWithNewlines);
    }
}

- (NSString *)stringByReplacingMultipleStrings:(NSDictionary <NSString *, NSString *>*)replacements
{
    NSString *ret = self;
    assert(![self contains:@"k9BBV15zFYi44YyB"]);

    for (NSString *key in replacements)
    {
        if ([[NSNull null] isEqual:key] || [[NSNull null] isEqual:replacements[key]])
            continue;
        ret = [ret stringByReplacingOccurrencesOfString:key
                                             withString:[key stringByAppendingString:@"k9BBV15zFYi44YyB"]];
    }

    BOOL replaced;
    do
    {
        replaced = FALSE;

        for (NSString *key in replacements)
        {
            id value = replacements[key];

            if ([[NSNull null] isEqual:key] || [[NSNull null] isEqual:value])
                continue;
            NSString *tmp = [ret stringByReplacingOccurrencesOfString:[key stringByAppendingString:@"k9BBV15zFYi44YyB"]
                                                           withString:value];

            if (![tmp isEqualToString:ret])
            {
                ret = tmp;
                replaced = YES;
            }
        }
    } while (replaced);

    return ret;
}

- (NSString *)capitalizedStringWithUppercaseWords:(NSArray <NSString *> *)uppercaseWords
{
    NSString *res = self.capitalizedString;

    for (NSString *word in uppercaseWords)
    {
        res = [res stringByReplacingOccurrencesOfString:makeString(@"(\\W)%@(\\W)", word.capitalizedString)
                                             withString:makeString(@"$1%@$2", word.uppercaseString)
                                                options:NSRegularExpressionSearch range: res.fullRange];
    }
    for (NSString *word in uppercaseWords)
    {
        res = [res stringByReplacingOccurrencesOfString:makeString(@"(\\W)%@(\\Z)", word.capitalizedString)
                                             withString:makeString(@"$1%@", word.uppercaseString)
                                                options:NSRegularExpressionSearch range:res.fullRange];
    }

    return res;
}

- (NSString *)titlecaseStringWithLowercaseWords:(NSArray <NSString *> *)lowercaseWords andUppercaseWords:(NSArray <NSString *> *)uppercaseWords
{
    NSString *res = [self capitalizedStringWithUppercaseWords:uppercaseWords];

    for (NSString *word in lowercaseWords)
    {
        res = [res stringByReplacingOccurrencesOfString:makeString(@"([^:,;,-]\\s)%@(\\s)", word.capitalizedString)
                                             withString:makeString(@"$1%@$2", word.lowercaseString)
                                                options:NSRegularExpressionSearch range: res.fullRange];

    }

    //    for (NSString *word in lowercaseWords)
    //    {
    //        res = [res stringByReplacingOccurrencesOfString:makeString(@"(\\s)%@(\\Z)", word.capitalizedString)
    //                                             withString:makeString(@"$1%@", word.lowercaseString)
    //                                                options:NSRegularExpressionSearch range: res.fullRange];
    //
    //    }

    return res;
}

- (NSString *)titlecaseString
{
    NSArray <NSString *>*words = @[@"a", @"an", @"the", @"and", @"but", @"for", @"nor", @"or", @"so", @"yet", @"at", @"by", @"for", @"in", @"of", @"off", @"on", @"out", @"to", @"up", @"via", @"to", @"c", @"ca", @"etc", @"e.g.", @"i.e.", @"vs.", @"vs", @"v", @"down", @"from", @"into", @"like", @"near", @"onto", @"over", @"than", @"with", @"upon"];

    return [self titlecaseStringWithLowercaseWords:words andUppercaseWords:nil];
}

- (NSString *)propercaseString
{
    if (self.length == 0)
        return @"";
    else if (self.length == 1)
        return self.uppercaseString;

    return makeString(@"%@%@",
                      [self substringToIndex:1].uppercaseString,
                      [self substringFromIndex:1].lowercaseString);
}

- (NSData *)download
{
#if defined(DEBUG) && !defined(SKIP_MAINTHREADDOWNLOAD_WARNING) && !defined(CLI)
    if ([NSThread currentThread] == [NSThread mainThread])
        cc_log(@"Warning: performing blocking download on main thread");
#endif
    NSData *d = [[NSData alloc] initWithContentsOfURL:self.URL];

    return d;
}

- (NSString *)downloadWithCurl
{
    return self.URL.downloadWithCurl;
}




#ifdef USE_SECURITY
- (NSString *)SHA1
{
    const char *cStr = self.UTF8String;
    if (!cStr) return nil;
    assert(CC_SHA1_DIGEST_LENGTH == 20);
    unsigned char result[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(cStr, (CC_LONG)strlen(cStr), result);
    NSString *s = [NSString  stringWithFormat:
                   @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                   result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7], result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15], result[16], result[17], result[18], result[19]
                   ];

    return s;
}
- (NSString *)SHA256
{
    const char *cStr = self.UTF8String;
    if (!cStr) return nil;

    assert(CC_SHA256_DIGEST_LENGTH == 32);
    unsigned char result[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(cStr, (CC_LONG)strlen(cStr), result);
    NSString *s = [NSString  stringWithFormat:
                   @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                   result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7], result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15], result[16], result[17], result[18], result[19], result[20], result[21], result[22], result[23], result[24], result[25], result[26], result[27], result[28], result[29], result[30], result[31]
                   ];

    return s;
}
#endif

- (NSMutableString *)mutableObject
{
    return [NSMutableString stringWithString:self];
}

- (NSString *)language
{
    CFStringRef resultLanguage;
    
    resultLanguage = CFStringTokenizerCopyBestStringLanguage((CFStringRef)self, CFRangeMake(0, self.length > 500 ? 500 : (long)self.length));
    
    return CFBridgingRelease(resultLanguage);
    
    
//   NSLinguisticTagger *tagger = [[NSLinguisticTagger alloc] initWithTagSchemes:@[NSLinguisticTagSchemeLanguage] options:0];
//   tagger.string = self;
//
//   NSString *resultLanguage = [tagger tagAtIndex:0 scheme:NSLinguisticTagSchemeLanguage tokenRange:NULL sentenceRange:NULL];
//   return resultLanguage;
    


    
//    __block NSString *resultLanguage;
//    dispatch_queue_t queue;
//    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
//    NSSpellChecker *spellChecker = NSSpellChecker.sharedSpellChecker;
//    spellChecker.automaticallyIdentifiesLanguages = YES;
//    [spellChecker requestCheckingOfString:self
//                                    range:(NSRange){0, self}
//                                    types:NSTextCheckingTypeOrthography
//                                  options:nil
//                   inSpellDocumentWithTag:0
//                        completionHandler:^(NSInteger sequenceNumber, NSArray *results, NSOrthography *orthography, NSInteger wordCount)
//     {
//         resultLanguage = orthography.dominantLanguage;
//         dispatch_semaphore_signal(sema);
//     }];
//
//
//    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
//    sema = NULL;
//
//    return resultLanguage;
}

- (NSString *)removedPrefix:(NSString *)stringToRemove
{
    if ([self hasPrefix:stringToRemove])
        return [self substringFromIndex:stringToRemove.length];
    else
        return self;
}

- (NSString *)removedSuffix:(NSString *)stringToRemove
{
    if ([self hasSuffix:stringToRemove])
        return [self substringToIndex:self.length-stringToRemove.length];
    else
        return self;
}

- (NSString *)removed:(NSString *)stringToRemove
{
    return [self stringByReplacingOccurrencesOfString:stringToRemove withString:@""];
}

- (NSString *)appended:(NSString *)str                                 // = stringByAppendingString
{
    return [self stringByAppendingString:str];
}

- (NSString *)replaced:(NSString *)str1 with:(NSString *)str2    // stringByReplacingOccurencesOfString:withString:
{
    assert(str2);
    return [self stringByReplacingOccurrencesOfString:str1 withString:str2];
}

- (NSArray <NSString *> *)split:(NSString *)sep                                // componentsSeparatedByString:
{
    return [self componentsSeparatedByString:sep];
}

- (NSString *)between:(NSString *)sep1 and:(NSString *)sep2
{
    return [[self splitAfterNull:sep1] splitBeforeNull:sep2]; // iif the first call yields nil, we still return nil
}

- (NSString *)splitBeforeFull:(NSString *)sep
{
    NSRange r = [self rangeOfString:sep];
    
    if (r.location == NSNotFound)
        return self;
    else
        return [self substringToIndex:r.location];
}

- (NSString *)splitAfterFull:(NSString *)sep
{
    NSRange r = [self rangeOfString:sep];
    
    if (r.location == NSNotFound)
        return self;
    else
        return [self substringFromIndex:r.location + r.length];
}

- (NSString *)splitBeforeNull:(NSString *)sep
{
    NSRange r = [self rangeOfString:sep];
    
    if (r.location == NSNotFound)
        return nil;
    else
        return [self substringToIndex:r.location];
}

- (NSString *)splitAfterNull:(NSString *)sep
{
    NSRange r = [self rangeOfString:sep];
    
    if (r.location == NSNotFound)
        return nil;
    else
        return [self substringFromIndex:r.location + r.length];
}

- (NSArray *)defaultArray
{
    assert(userDefaults);
    return [userDefaults arrayForKey:self];
}

- (void)setDefaultArray:(NSArray *)newDefault
{
    assert(userDefaults);
    [userDefaults setObject:newDefault forKey:self];
}

- (NSDictionary *)defaultDict
{
    assert(userDefaults);
    return [userDefaults dictionaryForKey:self];
}

- (void)setDefaultDict:(NSDictionary *)newDefault
{
    assert(userDefaults);
    [userDefaults setObject:newDefault forKey:self];
}

- (id)defaultObject
{
    assert(userDefaults);
    return [userDefaults objectForKey:self];
}

- (void)setDefaultObject:(id)newDefault
{
    assert(userDefaults);
    [userDefaults setObject:newDefault forKey:self];
}

- (NSString *)defaultString
{
    assert(userDefaults);
    return [userDefaults stringForKey:self];
}

- (void)setDefaultString:(NSString *)newDefault
{
    [userDefaults setObject:newDefault forKey:self];
}

- (NSURL *)defaultURL
{
    assert(userDefaults);
    return [userDefaults URLForKey:self];
}

- (void)setDefaultURL:(NSURL *)newDefault
{
    assert(userDefaults);
    [userDefaults setURL:newDefault forKey:self];
}

- (NSInteger)defaultInt
{
    assert(userDefaults);
    return [userDefaults integerForKey:self];
}

- (void)setDefaultInt:(NSInteger)newDefault
{
    assert(userDefaults);
    [userDefaults setInteger:newDefault forKey:self];
}

- (float)defaultFloat
{
    assert(userDefaults);
    return [userDefaults floatForKey:self];
}

- (void)setDefaultFloat:(float)newDefault
{
    assert(userDefaults);
    [userDefaults setFloat:newDefault forKey:self];
}

- (NSString *)stringValue
{
    return self;
}

//- (NSNumber *)numberValue
//{
//    return @(self.doubleValue);
//}

- (NSArray <NSArray <NSString *> *> *)parsedDSVWithDelimiter:(NSString *)delimiter
{    // credits to Drew McCormack
    NSMutableArray *rows = [NSMutableArray array];

    NSMutableCharacterSet *whitespaceCharacterSet = [NSMutableCharacterSet whitespaceCharacterSet];
    NSMutableCharacterSet *newlineCharacterSetMutable = [NSMutableCharacterSet whitespaceAndNewlineCharacterSet];
    [newlineCharacterSetMutable formIntersectionWithCharacterSet:whitespaceCharacterSet.invertedSet];
    [whitespaceCharacterSet removeCharactersInString:delimiter];
    NSCharacterSet *newlineCharacterSet = [NSCharacterSet characterSetWithBitmapRepresentation:newlineCharacterSetMutable.bitmapRepresentation];
    NSMutableCharacterSet *importantCharactersSetMutable = [NSMutableCharacterSet characterSetWithCharactersInString:[delimiter stringByAppendingString:@"\""]];
    [importantCharactersSetMutable formUnionWithCharacterSet:newlineCharacterSet];
    NSCharacterSet *importantCharactersSet = [NSCharacterSet characterSetWithBitmapRepresentation:importantCharactersSetMutable.bitmapRepresentation];

    NSScanner *scanner = [NSScanner scannerWithString:self];
    [scanner setCharactersToBeSkipped:nil];

    while (!scanner.atEnd)
    {
        BOOL insideQuotes = NO;
        BOOL finishedRow = NO;
        NSMutableArray *columns = [NSMutableArray arrayWithCapacity:30];
        NSMutableString *currentColumn = [NSMutableString string];

        while (!finishedRow)
        {
            NSString *tempString;
            if ([scanner scanUpToCharactersFromSet:importantCharactersSet intoString:&tempString])
            {
                [currentColumn appendString:tempString];
            }

            if (scanner.atEnd)
            {
                if (![currentColumn isEqualToString:@""])
                    [columns addObject:currentColumn];

                finishedRow = YES;
            }
            else if ([scanner scanCharactersFromSet:newlineCharacterSet intoString:&tempString])
            {
                if (insideQuotes)
                {
                    [currentColumn appendString:tempString];
                }
                else
                {
                    if (![currentColumn isEqualToString:@""])
                        [columns addObject:currentColumn];
                    finishedRow = YES;
                }
            }
            else if ([scanner scanString:@"\"" intoString:NULL])
            {
                if (insideQuotes && [scanner scanString:@"\"" intoString:NULL])
                {
                    [currentColumn appendString:@"\""];
                }
                else
                {
                    insideQuotes = !insideQuotes;
                }
            }
            else if ([scanner scanString:delimiter intoString:NULL])
            {
                if (insideQuotes)
                {
                    [currentColumn appendString:delimiter];
                }
                else
                {
                    [columns addObject:currentColumn];
                    currentColumn = [NSMutableString string];
                    [scanner scanCharactersFromSet:whitespaceCharacterSet intoString:NULL];
                }
            }
        }
        if (columns.count > 0)
            [rows addObject:columns];
    }

    return rows;
}

- (NSData *)data
{
    static const NSStringEncoding encodingsToTry[] = {NSUTF8StringEncoding, NSISOLatin1StringEncoding, NSASCIIStringEncoding, NSUnicodeStringEncoding};
    int encodingCount = (sizeof(encodingsToTry) / sizeof(NSStringEncoding));
    NSData *d;
    
    for (unsigned char i = 0; i < encodingCount; i++)
    {
        d = [self dataUsingEncoding:encodingsToTry[i] allowLossyConversion:YES];
        if (d)
            break;
    }
    
    if (!d)
        cc_log_error(@"Error: can not convert string to data!");
    
    return d;
}

- (NSData *)dataFromBase64String
{
    return [[NSData alloc] initWithBase64EncodedString:self options:NSDataBase64DecodingIgnoreUnknownCharacters];
}

- (NSData *)dataFromHexString
{
    const char *bytes = [self cStringUsingEncoding:NSUTF8StringEncoding];
    if (!bytes) return nil;
    NSUInteger length = strlen(bytes);
    unsigned char *r = (unsigned char *)malloc(length / 2 + 1);
    unsigned char *index = r;

    while ((*bytes) && (*(bytes +1)))
    {
        char encoder[3] = {'\0','\0','\0'};
        encoder[0] = *bytes;
        encoder[1] = *(bytes+1);
        *index = (unsigned char)strtol(encoder, NULL, 16);
        index++;
        bytes+=2;
    }
    *index = '\0';

    NSData *result = [NSData dataWithBytes:r length:length / 2];
    free(r);
    return result;
}

- (NSString *)unescaped
{
    return self.stringByRemovingPercentEncoding;
}

- (NSString *)escaped
{
    return [self stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
}

- (NSString *)escapedForXML
{
    NSString *str = self;
    
    str = [str stringByReplacingMultipleStrings:@{@"&" : @"&amp;",
                                                  @"\"" : @"&quot;",
                                                  @"'" : @"&#39;",
                                                  @">" : @"&gt;",
                                                  @"<" : @"&lt;"}];
           
    return str;
}

- (NSString *)escapedForHTML
{
    NSString *str = self;
    
    str = [str stringByReplacingMultipleStrings:@{@"À":@"&Agrave;",
                                                  @"Á":@"&Aacute;",
                                                  @"Â":@"&Acirc;",
                                                  @"Ã":@"&Atilde;",
                                                  @"Ä":@"&Auml;",
                                                  @"Å":@"&Aring;",
                                                  @"Æ":@"&AElig;",
                                                  @"Ç":@"&Ccedil;",
                                                  @"È":@"&Egrave;",
                                                  @"É":@"&Eacute;",
                                                  @"Ê":@"&Ecirc;",
                                                  @"Ë":@"&Euml;",
                                                  @"Ì":@"&Igrave;",
                                                  @"Í":@"&Iacute;",
                                                  @"Î":@"&Icirc;",
                                                  @"Ï":@"&Iuml;",
                                                  @"Ð":@"&ETH;",
                                                  @"Ñ":@"&Ntilde;",
                                                  @"Ò":@"&Ograve;",
                                                  @"Ó":@"&Oacute;",
                                                  @"Ô":@"&Ocirc;",
                                                  @"Õ":@"&Otilde;",
                                                  @"Ö":@"&Ouml;",
                                                  @"Ø":@"&Oslash;",
                                                  @"Ù":@"&Ugrave;",
                                                  @"Ú":@"&Uacute;",
                                                  @"Û":@"&Ucirc;",
                                                  @"Ü":@"&Uuml;",
                                                  @"Ý":@"&Yacute;",
                                                  @"Þ":@"&THORN;",
                                                  @"ß":@"&szlig;",
                                                  @"à":@"&agrave;",
                                                  @"á":@"&aacute;",
                                                  @"â":@"&acirc;",
                                                  @"ã":@"&atilde;",
                                                  @"ä":@"&auml;",
                                                  @"å":@"&aring;",
                                                  @"æ":@"&aelig;",
                                                  @"ç":@"&ccedil;",
                                                  @"è":@"&egrave;",
                                                  @"é":@"&eacute;",
                                                  @"ê":@"&ecirc;",
                                                  @"ë":@"&euml;",
                                                  @"ì":@"&igrave;",
                                                  @"í":@"&iacute;",
                                                  @"î":@"&icirc;",
                                                  @"ï":@"&iuml;",
                                                  @"ð":@"&eth;",
                                                  @"ñ":@"&ntilde;",
                                                  @"ò":@"&ograve;",
                                                  @"ó":@"&oacute;",
                                                  @"ô":@"&ocirc;",
                                                  @"õ":@"&otilde;",
                                                  @"ö":@"&ouml;",
                                                  @"ø":@"&oslash;",
                                                  @"ù":@"&ugrave;",
                                                  @"ú":@"&uacute;",
                                                  @"û":@"&ucirc;",
                                                  @"ü":@"&uuml;",
                                                  @"ý":@"&yacute;",
                                                  @"þ":@"&thorn;",
                                                  @"ÿ":@"&yuml;"}];
           
    return str;
}


- (NSString *)slicingSubstringFromIndex:(NSInteger)location
{
    if (location < 0)
    {
        NSInteger max = (NSInteger)self.length + location;
        return [self substringFromIndex:(NSUInteger)max];
    }
    else
        return [self substringFromIndex:(NSUInteger)location];
}


- (NSString *)slicingSubstringToIndex:(NSInteger)location
{
    if (location < 0)
    {
        NSInteger max = (NSInteger)self.length + location;
        return [self substringToIndex:(NSUInteger)max];
    }
    else
        return [self substringToIndex:(NSUInteger)location];
}


- (NSString *)encoded
{
    return [self stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet alphanumericCharacterSet]];
}

- (NSString *)stringByTrimmingLeadingCharactersInSet:(NSCharacterSet *)characterSet
{
    NSRange rangeOfFirstWantedCharacter = [self rangeOfCharacterFromSet:characterSet.invertedSet];
    if (rangeOfFirstWantedCharacter.location == NSNotFound)
        return @"";

    return [self substringFromIndex:rangeOfFirstWantedCharacter.location];
}

- (NSString *)stringByTrimmingTrailingCharactersInSet:(NSCharacterSet *)characterSet
{
    NSRange rangeOfLastWantedCharacter = [self rangeOfCharacterFromSet:characterSet.invertedSet
                                                               options:NSBackwardsSearch];
    if (rangeOfLastWantedCharacter.location == NSNotFound)
        return @"";

    return [self substringToIndex:rangeOfLastWantedCharacter.location+1];
}

- (NSString *)stringByDeletingCharactersInSet:(NSCharacterSet *)characterSet
{
    NSRange r = [self rangeOfCharacterFromSet:characterSet];
    NSString *new = self.copy;
    
    while (r.location != NSNotFound)
    {
        new = [new stringByReplacingCharactersInRange:r withString:@""];
        r = [new rangeOfCharacterFromSet:characterSet];
    }
    return new;
}

- (NSString *)stringByDeduplicatingSuccessiveIdenticalLines
{
    let lines = self.lines;
    let array = (NSMutableArray <NSString *> *)[NSMutableArray arrayWithCapacity:lines.count];
    
    for (NSString *line in lines)
    {
        NSString *lastLine = array.lastObject; // false-positive in compiler warning with Xcode 14.3 when using var/let
        if (![line isEqualToString:lastLine])
            [array addObject:line];
    }
    return array.joinedWithNewlines;
}

#if CL_TARGET_OSX
void directoryObservingReleaseCallback(const void *info)
{
    CFBridgingRelease(info);
}

void directoryObservingEventCallback(ConstFSEventStreamRef streamRef, void *clientCallBackInfo, size_t numEvents, void *eventPaths, const FSEventStreamEventFlags eventFlags[], const FSEventStreamEventId eventIds[])
{
    NSMutableArray <NSDictionary *> *tmp = makeMutableArray();
    char **paths = eventPaths;
    for (NSUInteger i = 0; i < numEvents; i++)
    {
        char *eventPath = paths[i];

        if (eventPath)
        {
            NSString *eventPathString = @(eventPath);
            if (eventPathString)
                [tmp addObject:@{@"path" : eventPathString, @"flags" : @(eventFlags[i])}];
        }
    }

    void (^block)(id input) = (__bridge void (^)(id))(clientCallBackInfo);
    dispatch_async_main(^{ block(tmp); });
//
//    void (^block)(void) = (__bridge void (^)(void))(clientCallBackInfo);
//    block();
}

CONST_KEY(CCDirectoryObserving)
- (NSValue *)startObserving:(ObjectInBlock)block withFileLevelEvents:(BOOL)fileLevelEvents
{
    void *ptr = (__bridge_retained void *)block;
    FSEventStreamContext context = {0, ptr, NULL, directoryObservingReleaseCallback, NULL};
    CFStringRef mypath = (__bridge CFStringRef)self.stringByExpandingTildeInPath;
    CFArrayRef pathsToWatch = CFArrayCreate(NULL, (const void **)&mypath, 1, NULL);
    FSEventStreamRef stream;
    CFAbsoluteTime latency = 2.0;


    assert(self.fileURL.fileIsDirectory || self.fileURL.fileIsBundle);
    stream = FSEventStreamCreate(NULL, &directoryObservingEventCallback, &context, pathsToWatch, kFSEventStreamEventIdSinceNow, latency, fileLevelEvents ? kFSEventStreamCreateFlagFileEvents : 0);

    CFRelease(pathsToWatch);
    dispatch_queue_t fileEventsObservationQueue = dispatch_queue_create("fileEventsObservationQueue", NULL);
    FSEventStreamSetDispatchQueue(stream, fileEventsObservationQueue);
    FSEventStreamStart(stream);

    NSValue *token = [NSValue valueWithPointer:stream];
    [self setAssociatedValue:token forKey:kCCDirectoryObservingKey];
    return token;
}

- (void)stopObserving:(NSValue *)token
{
    NSValue *v = [self associatedValueForKey:kCCDirectoryObservingKey];
    if (!v)
        v = token;
    
    if (v)
    {
        FSEventStreamRef stream = v.pointerValue;

        FSEventStreamStop(stream);
        FSEventStreamInvalidate(stream);
        FSEventStreamRelease(stream);
    }
    else
        cc_log_debug(@"Warning: stopped observing on location which was never observed %@", self);
}
#endif
@end
