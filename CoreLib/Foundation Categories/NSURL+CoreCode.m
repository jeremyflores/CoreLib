//
//  NSURL+CoreCode.m
//  MacUpdater
//
//  Created by Carterhaugh LLC on 8/16/23.
//  Copyright © 2023 CoreCode Limited. All rights reserved.
//

#import "NSURL+CoreCode.h"

#import "CLSecurityImport.h"
#import "CLLogging.h"
#import "CLGlobals.h"
#import "CLRunShCommand.h"

#import "NSArray+CoreCode.h"
#import "NSString+CoreCode.h"

#if __has_feature(modules)
@import Darwin.POSIX.sys.stat;
#else
#include <sys/stat.h>
#endif

@implementation NSURL (CoreCode)

@dynamic directoryContents, directoryContentsRecursive, fileExists, uniqueFile, request, mutableRequest, fileSize, directorySize, isWriteablePath, download, downloadWithCurl, contents, fileIsDirectory, fileIsQuarantined, fileOrDirectorySize, fileChecksumSHA, fileCreationDate, fileModificationDate; // , path

#if CL_TARGET_CLI || CL_TARGET_OSX
@dynamic fileIsAlias, fileAliasTarget, fileIsRestricted, fileIsRegularFile, fileIsSymlink;
#endif


- (NSString *)fileChecksumSHA
{
#ifdef USE_SECURITY
    if (self.fileExists)
    {
        NSData *d = [NSData dataWithContentsOfURL:self];
        unsigned char result[CC_SHA1_DIGEST_LENGTH];
        CC_SHA1(d.bytes, (CC_LONG)d.length, result);
        NSMutableString *ms = [NSMutableString string];
        
        for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        {
            [ms appendFormat: @"%02x", (int)(result [i])];
        }
        
        return [ms copy];
    }
    else
        return @"NoFile";
#else
    return @"Unvailable";
#endif
}


#if CL_TARGET_CLI || CL_TARGET_OSX
- (BOOL)fileIsRestricted
{
    struct stat info;
    lstat(self.path.UTF8String, &info);
    return (info.st_flags & SF_RESTRICTED) > 0;
}

- (BOOL)fileIsAlias
{
    CFURLRef cfurl = (__bridge CFURLRef) self;
    CFBooleanRef aliasBool = kCFBooleanFalse;
    Boolean success = CFURLCopyResourcePropertyForKey(cfurl, kCFURLIsAliasFileKey, &aliasBool, NULL);
    Boolean alias = CFBooleanGetValue(aliasBool);

    return alias && success;
}

- (BOOL)fileIsRegularFile
{
    NSNumber *value;
    [self getResourceValue:&value forKey:NSURLIsRegularFileKey error:NULL];
    return value.boolValue;
}


- (BOOL)fileIsSymlink
{
    CFURLRef cfurl = (__bridge CFURLRef) self;
    CFBooleanRef aliasBool = kCFBooleanFalse;
    Boolean success = CFURLCopyResourcePropertyForKey(cfurl, kCFURLIsSymbolicLinkKey, &aliasBool, NULL);
    Boolean alias = CFBooleanGetValue(aliasBool);
    
    return alias && success;
}

- (BOOL)fileIsQuarantined
{
    NSNumber *value;
    [self getResourceValue:&value forKey:NSURLQuarantinePropertiesKey error:NULL];
    return value.boolValue;
}

- (BOOL)fileIsDirectory
{
    NSNumber *value;
    [self getResourceValue:&value forKey:NSURLIsDirectoryKey error:NULL];
    return value.boolValue;
}

- (BOOL)fileIsBundle
{
    NSNumber *value;
    [self getResourceValue:&value forKey:NSURLIsPackageKey error:NULL];
    return value.boolValue;
}

- (NSURL *)fileAliasTarget
{
    CFErrorRef *err = NULL;
    CFDataRef bookmark = CFURLCreateBookmarkDataFromFile(NULL, (__bridge CFURLRef)self, err);
    if (bookmark == nil)
        return nil;
    CFURLRef url = CFURLCreateByResolvingBookmarkData (NULL, bookmark, kCFBookmarkResolutionWithoutUIMask, NULL, NULL, NULL, err);
    __autoreleasing NSURL *nurl = [(__bridge NSURL *)url copy];
    CFRelease(bookmark);
    CFRelease(url);

    return nurl;
}
#endif

- (NSData *)readFileHeader:(NSUInteger)maximumByteCount
{
    int fd = open(self.path.UTF8String, O_RDONLY);
    if (fd == -1)
        return nil;
    
    NSUInteger length = maximumByteCount;
    NSMutableData *data = [[NSMutableData alloc] initWithLength:length];
    
    if (data)
    {
        void *buffer = [data mutableBytes];
        
        long actualBytes = read(fd, buffer, length);
        
        if (actualBytes <= 0)
            data = nil;
        else  if ((NSUInteger)actualBytes < length)
            [data setLength:(NSUInteger)actualBytes];
    }
    close(fd);
    
    return data;
}


- (NSURLRequest *)request
{
    return [NSURLRequest requestWithURL:self];
}

- (NSMutableURLRequest *)mutableRequest
{
    return [NSMutableURLRequest requestWithURL:self];
}

- (NSURL *)add:(NSString *)component
{
    return [self URLByAppendingPathComponent:component];
}

- (NSArray <NSURL *> *)directoryContents
{
    assert(fileManager);
    if (!self.fileURL) return nil;

    
    NSArray <NSURL *>*res = [NSFileManager.defaultManager contentsOfDirectoryAtURL:self includingPropertiesForKeys:@[] options:0 error:NULL]; // this is a LOT faster (10 times) than using contentsOfDirectoryAtPath and converting to NSURLs
    return res;
}

- (NSArray <NSURL *> *)directoryContentsRecursive
{
    assert(fileManager);
    NSDirectoryEnumerator *enumerator = [fileManager
                                         enumeratorAtURL:self
                                         includingPropertiesForKeys:nil
                                         options:0
                                         errorHandler:^(NSURL *url, NSError *error) { return YES; }];
    
    return enumerator.allObjects;
}

- (NSURL *)uniqueFile
{
    if (!self.fileURL) return nil;
    return self.path.uniqueFile.fileURL;
}

- (BOOL)fileExists
{
    assert(fileManager);
    NSString *path = self.path;
    return self.fileURL && [fileManager fileExistsAtPath:path];
}


- (unsigned long long)fileOrDirectorySize
{
    return (self.fileIsDirectory ? self.directorySize : self.fileSize);
}

- (NSDate *)fileCreationDate
{
    NSDate *date;
    
    if ([self getResourceValue:&date forKey:NSURLCreationDateKey error:nil])
        return date;
    else
        return nil;
}

- (NSDate *)fileModificationDate
{
    NSDate *date;
    
    if ([self getResourceValue:&date forKey:NSURLContentModificationDateKey error:nil])
        return date;
    else
        return nil;
}

- (unsigned long long)fileSize
{
    NSNumber *size;
    
    if ([self getResourceValue:&size forKey:NSURLFileSizeKey error:nil])
        return size.unsignedLongLongValue;
    else
        return 0;
}

- (unsigned long long)directorySize
{
    assert(fileManager);
    unsigned long long directorySize = 0;
    
    NSDirectoryEnumerator *enumerator = [fileManager
                                         enumeratorAtURL:self
                                         includingPropertiesForKeys:@[NSURLIsDirectoryKey, NSURLFileSizeKey]
                                         options:0
                                         errorHandler:^(NSURL *url, NSError *error) { return YES; }];
    
    for (NSURL *url in enumerator)
    {
        NSDictionary *values = [url resourceValuesForKeys:@[NSURLIsDirectoryKey, NSURLFileSizeKey] error:NULL];
        if (values)
        {
            NSNumber *isDir = values[NSURLIsDirectoryKey];
            
            if (!isDir.boolValue)
            {
                NSNumber *fileSize = values[NSURLFileSizeKey];
                
                directorySize += fileSize.unsignedLongLongValue;
            }
        }
    }
    return directorySize;
}

- (void)open
{
#if CL_TARGET_OSX
    [NSWorkspace.sharedWorkspace openURL:self];
#elif CL_TARGET_IOS
    [UIApplication.sharedApplication openURL:self options:@{} completionHandler:NULL];
#elif CL_TARGET_CLI
    NSString *command = [NSString stringWithFormat:@"open \"%@\"", self.absoluteString];
    runShCommand(command);
#endif
}

- (BOOL)isWriteablePath
{
    assert(fileManager);
    if (self.fileExists)
        return NO;
    
    if (![@"TEST" writeToURL:self atomically:YES encoding:NSUTF8StringEncoding error:NULL])
        return NO;
    
    [fileManager removeItemAtURL:self error:NULL];
    
    return YES;
}


- (NSData *)download
{
#if defined(DEBUG) && !defined(SKIP_MAINTHREADDOWNLOAD_WARNING) && !defined(CLI)
    if ([NSThread currentThread] == [NSThread mainThread] && !self.isFileURL)
        cc_log(@"Warning: performing blocking download on main thread");
#endif

    NSData *d = [NSData dataWithContentsOfURL:self];

    return d;
}

#if defined(TARGET_OS_MAC) && TARGET_OS_MAC && !TARGET_OS_IPHONE
- (NSString *)downloadWithCurl
{
    NSString *urlString = self.absoluteString;
    NSString *res = [@[@"/usr/bin/curl", @"-m", @"30", @"-s", urlString] runAsTask];

    return res;
}
#endif

- (void)setContents:(NSData *)data
{
    NSError *err;
    
    if (!data)
        cc_log(@"Error: can not write null data to file %@", self.path);
    else if (![data writeToURL:self options:NSDataWritingAtomic error:&err])
        cc_log(@"Error: writing data to file has failed (file: %@ data: %lu error: %@)", self.path, (unsigned long)data.length, err.description);
}

- (NSData *)contents
{
    return self.download;
}

+ (NSURL *)URLWithHost:(NSString *)host path:(NSString *)path query:(NSString *)query
{
    return [NSURL URLWithHost:host path:path query:query user:nil password:nil fragment:nil scheme:@"https" port:nil];
}

+ (NSURL *)URLWithHost:(NSString *)host path:(NSString *)path query:(NSString *)query user:(NSString *)user password:(NSString *)password fragment:(NSString *)fragment scheme:(NSString *)scheme port:(NSNumber *)port
{
    assert([path hasPrefix:@"/"]);
    assert(![query contains:@"k9BBV15zFYi44YyB"]);
    query = [query replaced:@"+" with:@"k9BBV15zFYi44YyB"];
    NSURLComponents *urlComponents = [NSURLComponents new];
    urlComponents.scheme = scheme;
    urlComponents.host = host;
    urlComponents.path = path;
    urlComponents.query = query;
    urlComponents.user = user;
    urlComponents.password = password;
    urlComponents.fragment = fragment;
    urlComponents.port = port;
    urlComponents.percentEncodedQuery = [urlComponents.percentEncodedQuery replaced:@"k9BBV15zFYi44YyB" with:@"%2B"];

    NSURL *url = urlComponents.URL;
    assert(url);

    return url;
}

- (NSData *)performBlockingPOST:(double)timeoutSeconds
{
    __block NSData *data;
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);

    [self performPOST:^(NSData *d)
     {
         data = d;
         dispatch_semaphore_signal(sem);
     }];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeoutSeconds * NSEC_PER_SEC));
    long res = dispatch_semaphore_wait(sem, popTime);
    if (res == 0)
        return data;
    else
        return nil; // got timeout
}

- (NSData *)performBlockingGET:(double)timeoutSeconds
{
    __block NSData *data;
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);

    [self performGET:^(NSData *d)
    {
        data = d;
        dispatch_semaphore_signal(sem);
    }];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeoutSeconds * NSEC_PER_SEC));
    long res = dispatch_semaphore_wait(sem, popTime);
    if (res == 0)
        return data;
    else
        return nil; // got timeout
}

- (void)performGET:(void (^)(NSData *data))completion
{
    NSURLSessionDataTask *dataTask = [NSURLSession.sharedSession dataTaskWithURL:self completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
    {
        completion(data);
    }];
    [dataTask resume];
}

- (void)performPOST:(void (^)(NSData *data))completion
{
    NSURL *newURL = [NSURL URLWithHost:self.host path:self.path query:nil user:self.user
                              password:self.password fragment:self.fragment scheme:self.scheme port:self.port]; // don't want the query in there
    NSMutableURLRequest *request = newURL.request.mutableCopy;

    request.HTTPBody = self.query.data;
    request.HTTPMethod = @"POST";
    [request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];

    NSURLSessionDataTask *dataTask = [NSURLSession.sharedSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
    {
        completion(data);
    }];
    [dataTask resume];
}
@end
