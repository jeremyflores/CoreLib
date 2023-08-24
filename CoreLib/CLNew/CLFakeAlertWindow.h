//
//  CLFakeAlertWindow.h
//  MacUpdater
//
//  Created by Carterhaugh LLC on 8/15/23.
//  Copyright © 2023 CoreCode Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CLTarget.h"
#import "CLUIImport.h"

#if CL_TARGET_OSX
@interface CLFakeAlertWindow : NSWindow
@end
#endif
