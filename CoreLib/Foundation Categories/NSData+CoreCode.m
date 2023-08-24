//
//  NSData+CoreCode.m
//  MacUpdater
//
//  Created by Carterhaugh LLC on 8/16/23.
//  Copyright © 2023 CoreCode Limited. All rights reserved.
//

#import "NSData+CoreCode.h"

#ifdef USE_SNAPPY
    #import <snappy/snappy-c.h>
#endif

#import "CLSecurityImport.h"
#import "CLLogging.h"

#import "NSString+CoreCode.h"

@implementation NSData (CoreCode)

@dynamic string, stringUTF8, hexString, base64String, mutableObject, JSONArray, JSONDictionary, fullRange;

#ifdef USE_SECURITY
@dynamic SHA1, SHA256;
#endif


#ifdef USE_SECURITY
- (NSString *)SHA1
{
    const char *cStr = self.bytes;
    assert(CC_SHA1_DIGEST_LENGTH == 20);
    unsigned char result[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(cStr, (CC_LONG)self.length, result);
    NSString *s = [NSString  stringWithFormat:
                   @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                   result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7], result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15], result[16], result[17], result[18], result[19]
                   ];

    return s;
}
- (NSString *)SHA256
{
    const char *cStr = self.bytes;
    assert(CC_SHA256_DIGEST_LENGTH == 32);
    unsigned char result[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(cStr, (CC_LONG)self.length, result);
    NSString *s = [NSString  stringWithFormat:
                   @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                   result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7], result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15], result[16], result[17], result[18], result[19], result[20], result[21], result[22], result[23], result[24], result[25], result[26], result[27], result[28], result[29], result[30], result[31]
                   ];

    return s;
}
#endif

#ifdef USE_SNAPPY
@dynamic snappyCompressed, snappyDecompressed;

- (NSData *)snappyDecompressed
{
    size_t uncompressedSize = 0;

    if (snappy_uncompressed_length(self.bytes, self.length, &uncompressedSize) != SNAPPY_OK )
    {
        cc_log_error(@"Error: can't calculate the uncompressed length!\n");
        return nil;
    }

    assert(uncompressedSize);

    char *buf = (char *)malloc(uncompressedSize);
    assert(buf);


    int res = snappy_uncompress(self.bytes, self.length, buf, &uncompressedSize);
    if (res != SNAPPY_OK)
    {
        cc_log_error(@"Error: can't uncompress the file!\n");
        free(buf);
        return nil;
    }


    NSData *d = [NSData dataWithBytesNoCopy:buf length:uncompressedSize];

    return d;
}

- (NSData *)snappyCompressed
{
    size_t output_length = snappy_max_compressed_length(self.length);
    char *buf = (char*)malloc(output_length);
    assert(buf);

    int res = snappy_compress(self.bytes, self.length, buf, &output_length);
    if (res != SNAPPY_OK )
    {
        cc_log_error(@"Error: problem compressing the file\n");
        free(buf);
        return nil;
    }

    NSData *d = [NSData dataWithBytesNoCopy:buf length:output_length];

    return d;
}
#endif

- (NSData *)xorWith:(NSData *)key
{ // credits to Leszek S / LSCategories under the MIT license.
    if (key.length == 0)
        return self;
    
    NSMutableData *result = self.mutableCopy;
    
    unsigned char *bytes = (unsigned char *)result.mutableBytes;
    const unsigned char *keyStart = (const unsigned char *)key.bytes;
    const unsigned char *keyEnd = keyStart + key.length;
    const unsigned char *keyBytes = keyStart;
    NSUInteger length = result.length;
    
    for (NSUInteger i = 0; i < length; i++)
    {
        *bytes = *bytes ^ *keyBytes;
        bytes++;
        keyBytes++;
        if (keyBytes == keyEnd)
            keyBytes = keyStart;
    }
    return result.copy;
}

- (NSString *)string
{
    if (!self.length) return nil;
    
    NSString *result;
    unsigned long long magic;
    [self getBytes:&magic length:sizeof(unsigned long long)];

    // ok so stringEncodingForData sounds great, but sucks:
    // 1.) it can crash rdar://45371868
    // 2.) if we don't provide 'suggested encodings' it will often detect 'NSUTF7StringEncoding' which is nonsense so we have to provide it
    // 3.) however if we provide 'suggested encodings' it will misdetect Unicode as UTF8. we fix it by reading the magic marker
    
    BOOL lossy;
    NSDictionary *opt = @{ NSStringEncodingDetectionSuggestedEncodingsKey:@[ @(NSUTF8StringEncoding), @(NSISOLatin1StringEncoding), @(NSASCIIStringEncoding), @(NSUnicodeStringEncoding)] };
    if (magic == 0x78003F003CFEFF)
        opt = @{ NSStringEncodingDetectionSuggestedEncodingsKey:@[@(NSUnicodeStringEncoding)]};
    
#ifndef CLI
    NSStringEncoding enc =
#endif
    [NSString stringEncodingForData:self encodingOptions:opt convertedString:&result usedLossyConversion:&lossy];
    
    if (result)
    {
        if (lossy)
        {
#ifndef CLI
            cc_log(@"Warning: used lossy conversion %li data %@ => %lu / %@", enc, self, (unsigned long)result.length, [result clamp:20].strippedOfNewlines);
#endif
        }

        return result;
    }
    
    static const NSStringEncoding encodingsToTry[] = {NSUTF32StringEncoding, NSUnicodeStringEncoding, NSUTF8StringEncoding, NSISOLatin1StringEncoding, NSASCIIStringEncoding};
    int encodingCount = (sizeof(encodingsToTry) / sizeof(NSStringEncoding));
    
    for (unsigned char i = 0; i < encodingCount; i++)
    {
        NSString *s = [[NSString alloc] initWithData:self encoding:encodingsToTry[i]];

        if (!s)
            continue;

        cc_log_error(@"Error: used fallback conversion %li data %@ => %lu / %@", encodingsToTry[i], self, (unsigned long)s.length, [s clamp:20]);

        return s;
    }

    if (self.length < 200)
        cc_log_error(@"Error: could not create string from data %@", self);
    else
        cc_log_error(@"Error: could not create string from data %@", [self subdataWithRange:NSMakeRange(0,150)]);

    return nil;
}

- (NSString *)stringUTF8
{
    NSString *s = [[NSString alloc] initWithData:self encoding:NSUTF8StringEncoding];
    
#ifndef CLI
    if (!s)
    {
        NSUInteger maximumStringOutput = 100;
        if (self.length <= maximumStringOutput)
            cc_log_error(@"Error: could not create UTF8 string from data %@", self);
        else
            cc_log_error(@"Error: could not create UTF8 string from data %@", [self subdataWithRange:NSMakeRange(0, maximumStringOutput)]);
    }
#endif
    
    return s;
}

- (NSString *)base64String
{
    return [self base64EncodedStringWithOptions:(NSDataBase64EncodingOptions)0];
}

- (NSString *)hexString
{
    const unsigned char *dataBuffer = (const unsigned char *)self.bytes;

    if (!dataBuffer)
        return [NSString string];

    NSUInteger          dataLength  = self.length;
    NSMutableString     *hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];

    for (NSUInteger i = 0; i < dataLength; ++i)
        [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];

    return [NSString stringWithString:hexString];
}

- (NSMutableData *)mutableObject
{
    return [NSMutableData dataWithData:self];
}

- (id)JSONObject
{
    NSError *err;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:self options:(NSJSONReadingOptions)0 error:&err]; // on 10.15 this can crash ( +[NSJSONSerialization JSONObjectWithData:options:error:] + 94 => -[_NSJSONReader parseData:options:] + 240 => -[_NSJSONReader parseUTF8JSONData:skipBytes:options:] + 284 => newJSONValue + 1672 => newJSONValue + 3429 => __NSDictionaryI_new + 358 => objc_msgSend + 41 )

    if (!dict || err)
    {
        cc_log_error(@"Error: JSON read fails! input %@ dict %@ err %@", self, dict, err);
        return nil;
    }

    return dict;
}

- (NSArray *)JSONArray
{
    NSArray *res = (NSArray *)[self JSONObject];

    if (![res isKindOfClass:[NSArray class]])
    {
#ifndef SLIENCE_JSON_UNEXPECTEDCLASS_MESSAGES
        cc_log_error(@"Error: JSON read fails! input is class %@ instead of array", [[res class] description]);
#endif
        return nil;
    }

    return res;
}

- (NSDictionary *)JSONDictionary
{
    NSDictionary *res = (NSDictionary *)[self JSONObject];

    if (![res isKindOfClass:[NSDictionary class]])
    {
#ifndef SLIENCE_JSON_UNEXPECTEDCLASS_MESSAGES
        cc_log_error(@"Error: JSON read fails! input is class %@ instead of dictionary", [[res class] description]);
#endif
        return nil;
    }

    return res;
}


- (NSRange)fullRange
{
    return NSMakeRange(0, self.length);
}
@end
