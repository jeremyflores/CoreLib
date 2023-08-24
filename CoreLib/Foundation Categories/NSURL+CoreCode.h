//
//  NSURL+CoreCode.h
//  MacUpdater
//
//  Created by Carterhaugh LLC on 8/16/23.
//  Copyright © 2023 CoreCode Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CLTarget.h"

@interface NSURL (CoreCode)

+ (NSURL *)URLWithHost:(NSString *)host path:(NSString *)path query:(NSString *)query;
+ (NSURL *)URLWithHost:(NSString *)host path:(NSString *)path query:(NSString *)query user:(NSString *)user password:(NSString *)password fragment:(NSString *)fragment scheme:(NSString *)scheme port:(NSNumber *)port;
- (NSData *)performBlockingPOST:(double)timeoutSeconds;
- (NSData *)performBlockingGET:(double)timeoutSeconds;
- (void)performGET:(void (^)(NSData *data))completion;
- (void)performPOST:(void (^)(NSData *data))completion;

- (NSData *)readFileHeader:(NSUInteger)maximumByteCount;

- (NSURL *)add:(NSString *)component;
- (void)open;

@property (readonly, nonatomic) BOOL fileIsDirectory;
@property (readonly, nonatomic) BOOL fileIsQuarantined;
//@property (readonly, nonatomic) NSString *path;
@property (readonly, nonatomic) NSArray <NSURL *> *directoryContents;
@property (readonly, nonatomic) NSArray <NSURL *> *directoryContentsRecursive;
@property (readonly, nonatomic) NSURL *uniqueFile;
@property (readonly, nonatomic) BOOL fileExists;
#if CL_TARGET_CLI || CL_TARGET_OSX
@property (readonly, nonatomic) BOOL fileIsBundle;
@property (readonly, nonatomic) BOOL fileIsRestricted;
@property (readonly, nonatomic) BOOL fileIsAlias;
@property (readonly, nonatomic) BOOL fileIsRegularFile;
@property (readonly, nonatomic) BOOL fileIsSymlink;
@property (readonly, nonatomic) NSURL *fileAliasTarget;
#endif
@property (readonly, nonatomic) NSDate *fileCreationDate;
@property (readonly, nonatomic) NSDate *fileModificationDate;
@property (readonly, nonatomic) unsigned long long fileSize;
@property (readonly, nonatomic) unsigned long long fileOrDirectorySize;
@property (readonly, nonatomic) unsigned long long directorySize;

@property (readonly, nonatomic) NSString *fileChecksumSHA;


@property (readonly, nonatomic) NSURLRequest *request;
@property (readonly, nonatomic) NSMutableURLRequest *mutableRequest;
@property (readonly, nonatomic) BOOL isWriteablePath;
// url string download
@property (readonly, nonatomic) NSData *download;
@property (readonly, nonatomic) NSString *downloadWithCurl;
// path string filedata
@property (unsafe_unretained, nonatomic) NSData *contents;


@end
