//
//  CLRandom.h
//  MacUpdater
//
//  Created by Carterhaugh LLC on 8/15/23.
//  Copyright © 2023 CoreCode Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

CGFloat generateRandomFloatBetween(CGFloat a, CGFloat b);
int generateRandomIntBetween(int a, int b);

#define RANDOM_INIT             {srandom((unsigned)time(0));}
#define RANDOM_FLOAT(a,b)       ((a) + ((b) - (a)) * (random() / (CGFloat) RAND_MAX))
#define RANDOM_INT(a,b)         ((int)((a) + ((b) - (a) + 1) * (random() / (CGFloat) RAND_MAX)))        // this is INCLUSIVE; a and b will be part of the results
