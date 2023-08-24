//
//  CLMath.h
//  MacUpdater
//
//  Created by Carterhaugh LLC on 8/15/23.
//  Copyright © 2023 CoreCode Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MAX3(x,y,z)                (MAX(MAX((x),(y)),(z)))
#define MIN3(x,y,z)                (MIN(MIN((x),(y)),(z)))
#define BYTES_TO_KB(x)            ((double)(x) / (1024.0))
#define BYTES_TO_MB(x)            ((double)(x) / (1024.0 * 1024.0))
#define BYTES_TO_GB(x)            ((double)(x) / (1024.0 * 1024.0 * 1024.0))
#define KB_TO_BYTES(x)            ((x) * (1024))
#define MB_TO_BYTES(x)            ((x) * (1024 * 1024))
#define GB_TO_BYTES(x)            ((x) * (1024 * 1024 * 1024))
#define BYTES_TO_KB_NEW(x)      ((double)(x) / (1000.0))
#define BYTES_TO_MB_NEW(x)      ((double)(x) / (1000.0 * 1000.0))
#define BYTES_TO_GB_NEW(x)      ((double)(x) / (1000.0 * 1000.0 * 1000.0))
#define KB_TO_BYTES_NEW(x)      ((x) * (1000))
#define MB_TO_BYTES_NEW(x)      ((x) * (1000 * 1000))
#define GB_TO_BYTES_NEW(x)      ((x) * (1000 * 1000 * 1000))
#define SECONDS_PER_MINUTES(x)  ((x) * 60)
#define SECONDS_PER_HOURS(x)    (SECONDS_PER_MINUTES((x)) * 60)
#define SECONDS_PER_DAYS(x)     (SECONDS_PER_HOURS((x)) * 24)
#define SECONDS_PER_WEEKS(x)    (SECONDS_PER_DAYS((x)) * 7)

#define IS_FLOAT_EQUAL(x,y)        (fabsf((x)-(y)) < 0.0001f)
#define IS_DOUBLE_EQUAL(x,y)    (fabs((x)-(y)) < 0.000001)

#define IS_IN_RANGE(v,l,h)        (((v) >= (l)) && ((v) <= (h)))
#define CLAMP(x, low, high)        (((x) > (high)) ? (high) : (((x) < (low)) ? (low) : (x)))
