//
//  NSPredicate+CoreCode.h
//  MacUpdater
//
//  Created by Jeremy Flores on 3/7/24.
//  Copyright © 2024 CoreCode Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSPredicate (CoreCode)

+(instancetype)predicateWithPropertyRelata:(NSArray<NSString *> *)propertyRelata
                                   relation:(NSString *)relation
                              searchRelatum:(NSString *)searchRelatum
                              isConjunction:(BOOL)isConjunction;

@end

NS_ASSUME_NONNULL_END
