//
//  CLEnvironment.h
//  MacUpdater
//
//  Created by Carterhaugh LLC on 8/15/23.
//  Copyright © 2023 CoreCode Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CLTarget.h"

#if CL_TARGET_CLI || CL_TARGET_OSX
NSString *_machineType(void);
BOOL _isUserAdmin(void);
#endif
