//
//  CLOpenChoice.h
//  MacUpdater
//
//  Created by Carterhaugh LLC on 8/15/23.
//  Copyright © 2023 CoreCode Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CLTypes.h"

CC_ENUM(uint8_t, CLOpenChoice)
{
    openSupportRequestMail = 1,    // VendorProductPage info.plist key
    openBetaSignupMail,            // FeedbackEmail info.plist key
    openHomepageWebsite,        // VendorProductPage info.plist key
    openAppStoreWebsite,        // StoreProductPage info.plist key
    openAppStoreApp,            // StoreProductPage info.plist key
    openMacupdaternetWebsite    // MacupdaternetProductPage info.plist key
};
