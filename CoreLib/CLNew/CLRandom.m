//
//  CLRandom.m
//  MacUpdater
//
//  Created by Carterhaugh LLC on 8/15/23.
//  Copyright © 2023 CoreCode Limited. All rights reserved.
//

#import "CLRandom.h"

__inline__ CGFloat generateRandomFloatBetween(CGFloat a, CGFloat b)
{
    return a + (b - a) * (random() / (CGFloat) RAND_MAX);
}

__inline__ int generateRandomIntBetween(int a, int b)
{
    int range = b - a < 0 ? b - a - 1 : b - a + 1;
    long rand = random();
    int value = (int)(range * ((CGFloat)rand  / (CGFloat) RAND_MAX));
    return value == range ? a : a + value;
}
