//
//  CLConvenience.h
//  MacUpdater
//
//  Created by Carterhaugh LLC on 8/15/23.
//  Copyright © 2023 CoreCode Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

// !!!: CONVENIENCE MACROS
#define PROPERTY_STR(p)            NSStringFromSelector(@selector(p))
#define OBJECTS_EQUAL(x,y)      (((x) == nil && (y) == nil) || [(x) isEqual:(y)])

#define VALID_STR(x)            (((x) && ([x isKindOfClass:[NSString class]])) ? (x) : @"")
#define NON_NIL_STR(x)            ((x) ? (x) : @"")
#define NON_NIL_ARR(x)            ((x) ? (x) : @[])
#define NON_NIL_NUM(x)          ((x) ? (x) : @(0))
#define NON_NIL_OBJ(x)            ((x) ? (x) : [NSNull null])
#define NON_NSNULL_OBJ(x)       (([[NSNull null] isEqual:(x)]) ? nil : (x))
