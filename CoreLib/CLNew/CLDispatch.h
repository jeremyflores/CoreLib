//
//  CLDispatch.h
//  MacUpdater
//
//  Created by Carterhaugh LLC on 8/15/23.
//  Copyright © 2023 CoreCode Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CLTypes.h"

#define ASSERT_MAINTHREAD       assert_custom_info([NSThread currentThread] == [NSThread mainThread], makeString(@"main thread violation: %@", [NSThread.callStackSymbols joined:@"|"]))
#define ASSERT_BACKTHREAD       assert_custom_info([NSThread currentThread] != [NSThread mainThread], makeString(@"back thread violation: %@", [NSThread.callStackSymbols joined:@"|"]))

#define ONCE_PER_FUNCTION(b)    { static dispatch_once_t onceToken; dispatch_once(&onceToken, b); }
#define ONCE_PER_OBJECT(o,b)    @synchronized(o){ static dispatch_once_t onceToken; NSNumber *tokenNumber = [o associatedValueForKey:o.id]; onceToken = tokenNumber.longValue; dispatch_once(&onceToken, b); [o setAssociatedValue:@(onceToken) forKey:o.id]; }
#define ONCE_EVERY_MINUTES(b,m)    { static NSDate *time = nil; if (!time || [[NSDate date] timeIntervalSinceDate:time] > (m * 60)) { b(); time = [NSDate date]; }}

void dispatch_after_main(float seconds, dispatch_block_t block);
void dispatch_after_back(float seconds, dispatch_block_t block);
void dispatch_async_main(dispatch_block_t block);
void dispatch_async_back(dispatch_block_t block);
void dispatch_sync_main(dispatch_block_t block);
void dispatch_sync_back(dispatch_block_t block);
BOOL dispatch_sync_back_timeout(dispatch_block_t block, float timeoutSeconds); // returns 0 on succ

void dispatch_async_to_sync_resulthandler(id res);
id dispatch_async_to_sync(BasicBlock block);
