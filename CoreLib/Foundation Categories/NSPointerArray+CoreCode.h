//
//  NSPointerArray+CoreCode.h
//  MacUpdater
//
//  Created by Carterhaugh LLC on 8/16/23.
//  Copyright © 2023 CoreCode Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSPointerArray (CoreCode)

- (BOOL)containsPointer:(void *)aPointer;
- (NSInteger)getIndexOfPointer:(void *)aPointer;
- (void)forEach:(void (^)(void *))aCallback;
@end
