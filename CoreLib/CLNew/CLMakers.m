//
//  CLMakers.m
//  MacUpdater
//
//  Created by Carterhaugh LLC on 8/15/23.
//  Copyright © 2023 CoreCode Limited. All rights reserved.
//

#import "CLMakers.h"

#import "Foundation+CoreCode.h"

NSPredicate *makePredicate(NSString *format, ...)
{
    assert([format rangeOfString:@"'%@'"].location == NSNotFound);

    
    va_list args;
    va_start(args, format);
    NSPredicate *pred = [NSPredicate predicateWithFormat:format arguments:args];
    va_end(args);

    return pred;
}

NSDictionary<NSString *, id> * _makeDictionaryOfVariables(NSString *commaSeparatedKeysString, id firstValue, ...)
{
    NSUInteger i = 0;
    NSArray <NSString *> *argumentNames = [commaSeparatedKeysString split:@","];
    
    if (!argumentNames.count) return nil;
    
    NSMutableDictionary *dict = makeMutableDictionary();
    va_list args;
    va_start(args, firstValue);
    
    NSString *firstArgumentName = argumentNames.firstObject.trimmedOfWhitespaceAndNewlines;
    dict[firstArgumentName] = OBJECT_OR(firstValue, @"(null)");

    for (NSString *name in argumentNames)
    {
        if (i!=0)
        {
            id arg = va_arg(args, id);
            dict[name.trimmedOfWhitespaceAndNewlines] = OBJECT_OR(arg, @"(null)");
        }
        i++;
    }
    va_end(args);
    return dict;
}

NSString *makeDescription(NSObject *sender, NSArray *args)
{
    NSMutableString *dsc = [NSMutableString new];

    for (NSString *arg in args)
    {
        NSObject *value = [sender valueForKey:arg];
        NSString *d = [value description];

        [dsc appendFormat:@"\n%@: %@", arg, d];
    }

    return dsc.immutableObject;
}

NSString *makeLocalizedString(NSString *format, ...)
{
    va_list args;
    va_start(args, format);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wformat-nonliteral"
    NSString *str = [[NSString alloc] initWithFormat:format.localized arguments:args];
#pragma clang diagnostic pop
    va_end(args);
    
    return str;
}

NSString *makeStringC(const char * __restrict format, ...)
{
    va_list args;
    va_start(args, format);

    
    char *resC;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wformat-nonliteral"
    vasprintf(&resC, format, args);
#pragma clang diagnostic pop
    NSString *resOBJC = @(resC);
    
    free(resC);
    va_end(args);

    return resOBJC;
}

NSString *makeString(NSString *format, ...)
{
    va_list args;
    va_start(args, format);
    NSString *str = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    return str;
}

NSString *makeTempDirectory(BOOL useReplacementDirectory)
{
    NSError *error = nil;

    if (useReplacementDirectory)
    {
        NSURL *temporaryDirectoryURL =
            [fileManager URLForDirectory:NSItemReplacementDirectory
                                inDomain:NSUserDomainMask
                       appropriateForURL:NSHomeDirectory().fileURL
                                  create:YES
                                   error:&error];
        
        assert(temporaryDirectoryURL && !error);
        
        let result = temporaryDirectoryURL.path;
        
        assert(![result hasSuffix:@"/"]);
        
        return result;
        
        // this should return a new folder inside the 'TemporaryItems' subfolder of the tmp folder which is cleared on reboot.
        // sample path on 12.0 /var/folders/9c/bdxcbnjd29d1ql3h9zfsflp80000gn/T/TemporaryItems/NSIRD_#{appname}_89KPkg/
        // sample path on 11.0 /var/folders/9c/bdxcbnjd29d1ql3h9zfsflp80000gn/T/TemporaryItems/(A Document Being Saved By #{appname})
    }
    else
    {
        NSString *result = @[NSTemporaryDirectory(), NSProcessInfo.processInfo.globallyUniqueString].path;
        result = result.uniqueFile;
#ifdef DEBUG
        BOOL succ =
#endif
        [fileManager createDirectoryAtPath:result withIntermediateDirectories:YES attributes:nil error:nil];
        
#ifdef DEBUG
        assert(result && succ && !error);
        assert(![result hasSuffix:@"/"]);
#endif
        
        return result;
        
        // this should return a new folder inside the '$(TMPDIR)' folder which is ??
    }
}

NSString *makeTempFilepath(NSString *extension)
{
    NSString *tempDir = makeTempDirectory(YES);
    if (!tempDir)
        return nil;
    NSString *fileName = [@"1." stringByAppendingString:extension];
    NSString *filePath = @[tempDir, fileName].path;
    NSString *finalPath = filePath.uniqueFile;

    return finalPath;
}

#if CL_TARGET_IOS || CL_TARGET_OSX
NSValue *makeRectValue(CGFloat x, CGFloat y, CGFloat width, CGFloat height)
{
#if CL_TARGET_OSX
    return [NSValue valueWithRect:CGRectMake(x, y, width, height)];
#else
    return [NSValue valueWithCGRect:CGRectMake(x, y, width, height)];
#endif
}
#endif

#if CL_TARGET_OSX
NSColor *makeColor(CGFloat r, CGFloat g, CGFloat b, CGFloat a)
{
    return [NSColor colorWithCalibratedRed:(r) green:(g) blue:(b) alpha:(a)];
}
NSColor *makeColor255(CGFloat r, CGFloat g, CGFloat b, CGFloat a)
{
    return [NSColor colorWithCalibratedRed:(r) / 255.0 green:(g) / 255.0 blue:(b) / 255.0 alpha:(a) / 255.0];
}
#elif CL_TARGET_IOS
UIColor *makeColor(CGFloat r, CGFloat g, CGFloat b, CGFloat a)
{
    return [UIColor colorWithRed:(r) green:(g) blue:(b) alpha:(a)];
}
UIColor *makeColor255(CGFloat r, CGFloat g, CGFloat b, CGFloat a)
{
    return [UIColor colorWithRed:(r) / (CGFloat)255.0 green:(g) / (CGFloat)255.0 blue:(b) / (CGFloat)255.0 alpha:(a) / (CGFloat)255.0];
}
#endif
