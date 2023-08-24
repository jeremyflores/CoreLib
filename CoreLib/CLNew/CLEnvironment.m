//
//  CLEnvironment.m
//  MacUpdater
//
//  Created by Carterhaugh LLC on 8/15/23.
//  Copyright © 2023 CoreCode Limited. All rights reserved.
//

#import "CLEnvironment.h"

#import "CLTarget.h"

#if CL_TARGET_CLI || CL_TARGET_OSX
NSString *_machineType(void)
{
    Class hostInfoClass = NSClassFromString(@"JMHostInformation");
    
    if (hostInfoClass)
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        NSString *machineType = [hostInfoClass performSelector:@selector(machineType)];
#pragma clang diagnostic pop
        return machineType;
    }
    return @"";
}

BOOL _isUserAdmin(void)
{
    Class hostInfoClass = NSClassFromString(@"JMHostInformation");
    
    if (hostInfoClass)
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        NSMethodSignature *sig = [hostInfoClass methodSignatureForSelector:@selector(isUserAdmin)];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
        [invocation setSelector:@selector(isUserAdmin)];
#pragma clang diagnostic pop
        [invocation setTarget:hostInfoClass];
        [invocation invoke];
        BOOL returnValue;
        [invocation getReturnValue:&returnValue];
        return returnValue;
    }
    return YES;
}
#endif
