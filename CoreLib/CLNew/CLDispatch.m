//
//  CLDispatch.m
//  MacUpdater
//
//  Created by Carterhaugh LLC on 8/15/23.
//  Copyright © 2023 CoreCode Limited. All rights reserved.
//

#import "CLDispatch.h"

// gcd convenience
void dispatch_after_main(float seconds, dispatch_block_t block)
{
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), block);
}

void dispatch_after_back(float seconds, dispatch_block_t block)
{
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_global_queue(0, 0), block);
}

void dispatch_async_main(dispatch_block_t block)
{
    dispatch_async(dispatch_get_main_queue(), block);
}

void dispatch_async_back(dispatch_block_t block)
{
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    dispatch_async(queue, block);
}

void dispatch_sync_main(dispatch_block_t block)
{
    if ([NSThread currentThread] == [NSThread mainThread])
        block();    // using with dispatch_sync would deadlock when on the main thread
    else
        dispatch_sync(dispatch_get_main_queue(), block);
}

void dispatch_sync_back(dispatch_block_t block)
{
    dispatch_sync(dispatch_get_global_queue(0, 0), block);
}

BOOL dispatch_sync_back_timeout(dispatch_block_t block, float timeoutSeconds) // returns 0 on succ
{
    dispatch_block_t newblock = dispatch_block_create(DISPATCH_BLOCK_INHERIT_QOS_CLASS, block);
    dispatch_async(dispatch_get_global_queue(0, 0), newblock);
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeoutSeconds * NSEC_PER_SEC));
    return dispatch_block_wait(newblock, popTime) != 0;
}

static dispatch_semaphore_t ccAsyncToSyncSema;
static id ccAsyncToSyncResult;

void dispatch_async_to_sync_resulthandler(id res)
{
    assert(ccAsyncToSyncSema);
    assert(!ccAsyncToSyncResult);
    ccAsyncToSyncResult = res;
    dispatch_semaphore_signal(ccAsyncToSyncSema);
}

id dispatch_async_to_sync(BasicBlock block)
{
    assert(!ccAsyncToSyncResult);
    assert(!ccAsyncToSyncSema);
    ccAsyncToSyncSema = dispatch_semaphore_create(0);
    block();
    dispatch_semaphore_wait(ccAsyncToSyncSema, DISPATCH_TIME_FOREVER);
    assert(ccAsyncToSyncResult);
    ccAsyncToSyncSema = NULL;
    id copy = ccAsyncToSyncResult;
    ccAsyncToSyncResult = nil;
    return copy;
}
