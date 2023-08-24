//
//  PurchaseActivationType.h
//  MacUpdater
//
//  Created by Carterhaugh LLC on 8/18/23.
//  Copyright © 2023 CoreCode Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

CC_ENUM(uint8_t, purchaseActivationType)
{
    kPurchaseActivationFree = 0,
    kPurchaseActivationPaid = 1,
    kPurchaseActivationPro = 2
};
