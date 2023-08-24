//
//  NSDate+CoreCode.h
//  MacUpdater
//
//  Created by Carterhaugh LLC on 8/16/23.
//  Copyright © 2023 CoreCode Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (CoreCode)

+ (NSDate *)tomorrow;
+ (NSDate *)yesterday;
// date format strings:   dd.MM.yyyy HH:mm:ss
+ (NSDate *)dateWithString:(NSString *)dateString format:(NSString *)dateFormat localeIdentifier:(NSString *)localeIdentifier;
+ (NSDate *)dateWithString:(NSString *)dateString format:(NSString *)dateFormat;
+ (NSDate *)dateWithPreprocessorDate:(const char *)preprocessorDateString;
+ (NSDate *)dateWithRFC822Date:(NSString *)rfcDateString;       // e.g. Wed, 02 Oct 2002 15:00:00 +0200
+ (NSDate *)dateWithISO8601Date:(NSString *)iso8601DateString;  // e.g. 2019-03-15T05:18:44Z
+ (NSDate *)dateWithUnformattedDate:(NSString *)dateString; // uses NSDataDetector
- (NSString *)stringUsingFormat:(NSString *)dateFormat;
- (NSString *)stringUsingFormat:(NSString *)dateFormat timeZone:(NSTimeZone *)timeZone;
- (NSString *)stringUsingDateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle; // warning: this uses currentLocale and thus uses different output formats on different Macs
- (NSString *)stringUsingDateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle locale:(NSLocale *)locale;
- (NSDate *)nextDay;
- (NSDate *)previousDay;
- (BOOL)isLaterThan:(NSDate *)date;
- (BOOL)isEarlierThan:(NSDate *)date;
@property (readonly, nonatomic) NSString *shortDateString;                // warning: this uses currentLocale and thus uses different output formats on different Macs
@property (readonly, nonatomic) NSString *shortTimeString;                 // warning: this uses currentLocale and thus uses different output formats on different Macs
@property (readonly, nonatomic) NSString *shortDateAndTimeString;        // warning: this uses currentLocale and thus uses different output formats on different Macs
@property (readonly, nonatomic) NSString *shortDateStringPosix;
@property (readonly, nonatomic) NSString *shortTimeStringPosix;
@property (readonly, nonatomic) NSString *shortDateAndTimeStringPosix;

@end
