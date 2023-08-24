//
//  NSDate+CoreCode.m
//  MacUpdater
//
//  Created by Carterhaugh LLC on 8/16/23.
//  Copyright © 2023 CoreCode Limited. All rights reserved.
//

#import "NSDate+CoreCode.h"

#import "CLDispatch.h"

@implementation NSDate (CoreCode)

+ (NSDate *)tomorrow
{
    NSDateComponents *components = NSDateComponents.new;
    components.day = 1;
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDate *tomorrow = [gregorian dateByAddingComponents:components toDate:NSDate.date options:0];
    
    return tomorrow;
}
    
+ (NSDate *)yesterday
{
    NSDateComponents *components = NSDateComponents.new;
    components.day = -1;
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDate *yesterday = [gregorian dateByAddingComponents:components toDate:NSDate.date options:0];
    
    return yesterday;
}

- (NSDate *)nextDay
{
    NSDateComponents *components = NSDateComponents.new;
    components.day = 1;
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDate *tomorrow = [gregorian dateByAddingComponents:components toDate:self options:0];
    
    return tomorrow;
}

- (NSDate *)previousDay
{
    NSDateComponents *components = NSDateComponents.new;
    components.day = -1;
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDate *yesterday = [gregorian dateByAddingComponents:components toDate:self options:0];
    
    return yesterday;
}

- (BOOL)isLaterThan:(NSDate *)date
{
    return [self laterDate:date] == self;
}

- (BOOL)isEarlierThan:(NSDate *)date
{
    return [self earlierDate:date] == self;
}

+ (NSDate *)dateWithString:(NSString *)dateString format:(NSString *)dateFormat localeIdentifier:(NSString *)localeIdentifier
{
    NSDateFormatter *df = NSDateFormatter.new;
    df.dateFormat = dateFormat;
    NSLocale *l = [[NSLocale alloc] initWithLocaleIdentifier:localeIdentifier];
    df.locale = l;

    return [df dateFromString:dateString];
}

+ (NSDate *)dateWithString:(NSString *)dateString format:(NSString *)dateFormat
{
    return [self dateWithString:dateString format:dateFormat localeIdentifier:@"en_US_POSIX" ];
}

+ (NSDate *)dateWithUnformattedDate:(NSString *)dateString
{
    if (!dateString) return nil;
    
    __block NSDate *dd;
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingAllTypes error:nil];
    
    [detector enumerateMatchesInString:dateString
                               options:kNilOptions
                                 range:NSMakeRange(0, dateString.length)
                            usingBlock:^(NSTextCheckingResult *r, NSMatchingFlags f, BOOL *s) { dd = r.date; }];

    return dd;
}

+ (NSDate *)dateWithPreprocessorDate:(const char *)preprocessorDateString
{
    return [self dateWithString:@(preprocessorDateString) format:@"MMM d yyyy"];
}

+ (NSDate *)dateWithRFC822Date:(NSString *)rfcDateString
{
    NSDateFormatter *df = NSDateFormatter.new;
    
    df.dateFormat = @"EEE, dd MMM yyyy HH:mm:ss ZZZ";
    df.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    
    NSDate *result = [df dateFromString:rfcDateString];
    
    return result;
}

+ (NSDate *)dateWithISO8601Date:(NSString *)iso8601DateString
{   // there is the NSISO8601DateFormatter but its 10.12+
    
    static NSDateFormatter *df;
    
    ONCE_PER_FUNCTION(^
    {
        df = NSDateFormatter.new;
        df.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
        df.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    });
    
    NSDate *result = [df dateFromString:iso8601DateString];
    
    return result;
}

- (NSString *)stringUsingFormat:(NSString *)dateFormat
{
    return [self stringUsingFormat:dateFormat timeZone:nil];
}

- (NSString *)stringUsingFormat:(NSString *)dateFormat timeZone:(NSTimeZone *)timeZone
{
    static NSLocale *l;
    
    ONCE_PER_FUNCTION(^
    {
        l = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    });

    NSDateFormatter *df = NSDateFormatter.new;
    df.locale = l;
    df.dateFormat = dateFormat;
    if (timeZone)
        df.timeZone = timeZone;
    
    return [df stringFromDate:self];
}

- (NSString *)stringUsingDateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle locale:(NSLocale *)locale
{
    NSDateFormatter *df = NSDateFormatter.new;

    df.locale = locale;
    df.dateStyle = dateStyle;
    df.timeStyle = timeStyle;

    return [df stringFromDate:self];
}


- (NSString *)stringUsingDateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle
{
    return [self stringUsingDateStyle:dateStyle timeStyle:timeStyle locale:[NSLocale currentLocale]];
}

- (NSString *)shortDateString
{
    return [self stringUsingDateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle];
}

- (NSString *)shortTimeString
{
    return [self stringUsingDateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
}

- (NSString *)shortDateAndTimeString
{
    return [self stringUsingDateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
}

- (NSString *)shortDateStringPosix
{
    return [self stringUsingDateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle locale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
}

- (NSString *)shortTimeStringPosix
{
    return [self stringUsingDateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle locale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
}

- (NSString *)shortDateAndTimeStringPosix
{
    return [self stringUsingDateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle locale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
}

@end
