//
//  CLUIImport.h
//  MacUpdater
//
//  Created by Carterhaugh LLC on 8/15/23.
//  Copyright © 2023 CoreCode Limited. All rights reserved.
//

#import "CLTarget.h"

#if CL_TARGET_CLI

// no-op

#elif CL_TARGET_OSX

#if __has_feature(modules)
    @import Cocoa;
#else
    #import <Cocoa/Cocoa.h>
#endif
#if defined(MAC_OS_X_VERSION_MIN_REQUIRED) && MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_13
    #error CoreLib only deploys back to Mac OS X 10.13
#endif

#elif CL_TARGET_IOS

#if __has_feature(modules)
    @import UIKit;
#else
    #import <UIKit/UIKit.h>
#endif
#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED) && __IPHONE_OS_VERSION_MIN_REQUIRED < 80000
    #error CoreLib only deploys back to iOS 8
#endif

#endif
