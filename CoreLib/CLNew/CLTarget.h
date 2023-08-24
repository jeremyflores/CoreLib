//
//  CLTarget.h
//  MacUpdater
//
//  Created by Carterhaugh LLC on 8/15/23.
//  Copyright © 2023 CoreCode Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

#if !defined(CL_TARGET_CLI) || !defined(CL_TARGET_IOS) || !defined(CL_TARGET_OSX)

#if defined(TARGET_CLI) && TARGET_CLI
    #define CL_TARGET_CLI 1
    #define CL_TARGET_IOS 0
    #define CL_TARGET_OSX 0
#elif defined(TARGET_OS_MAC) && TARGET_OS_IPHONE    // TODO: double-check that this is correct
    #define CL_TARGET_CLI 0
    #define CL_TARGET_IOS 1
    #define CL_TARGET_OSX 0
#elif defined(TARGET_OS_MAC) && TARGET_OS_MAC
    #define CL_TARGET_CLI 0
    #define CL_TARGET_IOS 0
    #define CL_TARGET_OSX 1
#else // TODO: is `!defined(TARGET_OS_MAC)` possible for corelib?
    #define CL_TARGET_CLI 0
    #define CL_TARGET_IOS 0
    #define CL_TARGET_OSX 0
#endif

#endif
