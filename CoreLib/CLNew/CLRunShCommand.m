//
//  CLRunShCommand.m
//  MacUpdater
//
//  Created by Carterhaugh LLC on 8/18/23.
//  Copyright © 2023 CoreCode Limited. All rights reserved.
//

#import "CLRunShCommand.h"

#if CL_TARGET_CLI || CL_TARGET_OSX

// via: https://stackoverflow.com/a/12310154
NSString *runShCommand(NSString *command) {
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/sh"];

    NSArray *arguments = [NSArray arrayWithObjects:
                          @"-c" ,
                          [NSString stringWithFormat:@"%@", command],
                          nil];

    [task setArguments:arguments];

    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];

    NSFileHandle *file = [pipe fileHandleForReading];

    [task launch];

    NSData *data = [file readDataToEndOfFile];

    NSString *output = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    return output;
}

#endif
