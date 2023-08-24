//
//  CLSecurityImport.h
//  MacUpdater
//
//  Created by Carterhaugh LLC on 8/15/23.
//  Copyright © 2023 CoreCode Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef USE_SECURITY
#if __has_feature(modules)
@import CommonCrypto.CommonDigest;
#else
#include <CommonCrypto/CommonDigest.h>
#endif
#endif
