//
//  CLRunShCommand.h
//  MacUpdater
//
//  Created by Carterhaugh LLC on 8/18/23.
//  Copyright © 2023 CoreCode Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CLTarget.h"

NS_ASSUME_NONNULL_BEGIN

#if CL_TARGET_CLI || CL_TARGET_OSX
// synchronous
NSString *runShCommand(NSString *command);
#endif

NS_ASSUME_NONNULL_END
