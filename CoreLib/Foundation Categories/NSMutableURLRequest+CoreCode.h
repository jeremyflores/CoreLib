//
//  NSMutableURLRequest+CoreCode.h
//  MacUpdater
//
//  Created by Carterhaugh LLC on 8/16/23.
//  Copyright © 2023 CoreCode Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableURLRequest (CoreCode)

- (void)addBasicAuthentication:(NSString *)username password:(NSString *)password;

@end
