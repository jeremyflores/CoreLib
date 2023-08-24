//
//  NSURLRequest+CoreCode.m
//  MacUpdater
//
//  Created by Carterhaugh LLC on 8/16/23.
//  Copyright © 2023 CoreCode Limited. All rights reserved.
//

#import "NSURLRequest+CoreCode.h"

@implementation NSURLRequest (CoreCode)

@dynamic download;

- (NSData *)download
{
    return [self downloadWithTimeout:5 disableCache:YES];
}

- (NSData *)downloadWithTimeout:(double)timeoutSeconds disableCache:(BOOL)disableCache
{
    NSURLRequest *request = self;
    __block NSData *data;
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);

    NSURLSession *session = NSURLSession.sharedSession;
    if (disableCache)
    {
        NSMutableURLRequest *mutableRequest = self.mutableCopy;
        
        if (@available(macOS 10.15, *))
            mutableRequest.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
        else
            mutableRequest.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        
        NSURLSessionConfiguration *config = NSURLSessionConfiguration.defaultSessionConfiguration;

        if (@available(macOS 10.15, *))
            config.requestCachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
        else
            config.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    
        config.URLCache = nil;
        
        session = [NSURLSession sessionWithConfiguration:config];
        
        request = mutableRequest;
    }

    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable d, NSURLResponse * _Nullable response, NSError * _Nullable error)
    {
        data = d;
        dispatch_semaphore_signal(sem);
    }];
    [dataTask resume];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeoutSeconds * NSEC_PER_SEC));
    long res = dispatch_semaphore_wait(sem, popTime);
    if (res == 0)
        return data;
    else
        return nil; // got timeout
}

@end
