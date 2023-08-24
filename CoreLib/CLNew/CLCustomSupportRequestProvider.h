//
//  CLAppDelegate.h
//  MacUpdater
//
//  Created by Carterhaugh LLC on 8/15/23.
//  Copyright © 2023 CoreCode Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CLCustomSupportRequestProvider <NSObject>
@optional
- (NSString *)customSupportRequestAppName;
- (NSString *)customSupportRequestLicense;
- (NSString *)customSupportRequestPreferences;
- (NSString *)customSupportRequestText;
@end
