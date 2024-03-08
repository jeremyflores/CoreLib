//
//  NSPredicate+CoreCode.m
//  MacUpdater
//
//  Created by Jeremy Flores on 3/7/24.
//  Copyright © 2024 CoreCode Limited. All rights reserved.
//

#import "NSPredicate+CoreCode.h"

@implementation NSPredicate (CoreCode)

+(instancetype)predicateWithPropertyRelata:(NSArray<NSString *> *)propertyRelata
                                   relation:(NSString *)relation
                              searchRelatum:(NSString *)searchRelatum
                              isConjunction:(BOOL)isConjunction {
    NSString *joinOperator;
    if (isConjunction) {
        joinOperator = @"AND";
    }
    else {
        joinOperator = @"OR";
    }

    NSString *predicateFormat = @"";
    for (NSUInteger i=0; i<propertyRelata.count; i++) {
        NSString *propertyRelatum = propertyRelata[i];
        predicateFormat = [NSString stringWithFormat:@"%@ %@ %@ '%@'", predicateFormat, propertyRelatum, relation, searchRelatum];

        if (i<propertyRelata.count-1) {
            predicateFormat = [NSString stringWithFormat:@"%@ %@", predicateFormat, joinOperator];
        }
    }

    predicateFormat = [predicateFormat stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat];

    return predicate;
}

@end
