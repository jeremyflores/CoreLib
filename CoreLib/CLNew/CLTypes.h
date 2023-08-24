//
//  CLTypes.h
//  MacUpdater
//
//  Created by Carterhaugh LLC on 8/15/23.
//  Copyright © 2023 CoreCode Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef CGPoint CCFloatPoint;
typedef struct { NSInteger x; NSInteger y; } CCIntPoint;
typedef struct { CGFloat min; CGFloat max; CGFloat length; } CCFloatRange1D;
typedef struct { CCFloatPoint min; CCFloatPoint max; CCFloatPoint length; } CCFloatRange2D;
typedef struct { NSInteger min; NSInteger max; NSInteger length; } CCIntRange1D;
typedef struct { CCIntPoint min; CCIntPoint max; CCIntPoint length; } CCIntRange2D;

#ifdef __BLOCKS__
typedef void (^BasicBlock)(void);
typedef void (^DoubleInBlock)(double input);
typedef void (^StringInBlock)(NSString *input);
typedef void (^ObjectInBlock)(id input);
typedef id (^ObjectInOutBlock)(id input);
typedef int (^ObjectInIntOutBlock)(id input);
typedef float (^ObjectInFloatOutBlock)(id input);
typedef CCIntPoint (^ObjectInPointOutBlock)(id input);
typedef int (^IntInOutBlock)(int input);
typedef void (^IntInBlock)(int input);
typedef int (^IntOutBlock)(void);
#endif

#ifdef __cplusplus
#define CC_ENUM(type, name) enum class name : type
#else
#define CC_ENUM(type, name) typedef NS_ENUM(type, name)
#endif
