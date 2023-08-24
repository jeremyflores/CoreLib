//
//  NSMutableURLRequest+CoreCode.m
//  MacUpdater
//
//  Created by Carterhaugh LLC on 8/16/23.
//  Copyright © 2023 CoreCode Limited. All rights reserved.
//

#import "NSMutableURLRequest+CoreCode.h"

#import "CLMakers.h"

#import "NSData+CoreCode.h"
#import "NSString+CoreCode.h"

@implementation NSMutableURLRequest (CoreCode)

- (void)addBasicAuthentication:(NSString *)username password:(NSString *)password
{
    NSString *authStr = makeString(@"%@:%@", username, password);
    NSString *authValue = makeString(@"Basic %@", authStr.data.base64String);
    [self setValue:authValue forHTTPHeaderField:@"Authorization"];
}

@end
