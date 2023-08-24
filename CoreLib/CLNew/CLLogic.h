//
//  CLLogic.h
//  MacUpdater
//
//  Created by Carterhaugh LLC on 8/15/23.
//  Copyright © 2023 CoreCode Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

#define OBJECT_OR(x,y)            ((x) ? (x) : (y))
#define STRING_OR(x, y)            (((x) && ([x isKindOfClass:[NSString class]]) && ([((NSString *)x) length])) ? (x) : (y))
#define ARRAY_OR(x, y)          (((x) && ([x isKindOfClass:[NSArray class]]) && ([((NSArray *)x) count])) ? (x) : (y))

#define OBJECT_OR3(x,y,z)       OBJECT_OR((x),OBJECT_OR((y),(z)))
#define STRING_OR3(x,y,z)       STRING_OR((x),STRING_OR((y),(z)))


