//
//  JMCrashReporter.m
//  CoreLib
//
//  Created by CoreCode on 12.03.07.
/*	Copyright (c) 2015 CoreCode
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */


#import "JMCrashReporter.h"
#import "JMHostInformation.h"


#define kLastCrashDateKey		@"CoreLib_lastcrashdate"
#define kNeverCheckCrashesKey	@"CoreLib_nevercheckcrashes"

// parameters:
//	email:	email to report crashes to
//	neccessaryStrings:	a array of strings one of which must be contained for the report to be accepted

void CheckAndReportCrashes(NSString *email, NSArray *neccessaryStrings)
{
	if ([[NSUserDefaults standardUserDefaults] integerForKey:kNeverCheckCrashesKey] == 0)
	{
		NSString *path = nil;
		NSDate *newestcrashdate = [NSDate dateWithString:@"2007 01 01" format:@"yyyy dd MM"];

		{
			NSString *dpath = [@"~/Library/Logs/DiagnosticReports/" stringByExpandingTildeInPath];
			NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dpath error:NULL];

			NSString *fname;

			for (fname in contents)
			{
				if ([fname hasPrefix:cc.appName])
				{
					NSString *fullPath = [dpath stringByAppendingPathComponent:fname];
					NSDate *date = [[[NSFileManager defaultManager] attributesOfItemAtPath:fullPath error:NULL] objectForKey:@"NSFileModificationDate"];

					if ([date compare:newestcrashdate] == NSOrderedDescending)
					{
						newestcrashdate = date;
						path = fullPath;
					}
				}
			}
		}
		{
			NSString *dpath = [@"/Library/Logs/DiagnosticReports/" stringByExpandingTildeInPath];
			NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dpath error:NULL];

			NSString *fname;

			for (fname in contents)
			{
				if ([fname hasPrefix:cc.appName])
				{
					NSString *fullPath = [dpath stringByAppendingPathComponent:fname];
					NSDate *date = [[[NSFileManager defaultManager] attributesOfItemAtPath:fullPath error:NULL] objectForKey:@"NSFileModificationDate"];

					if ([date compare:newestcrashdate] == NSOrderedDescending)
					{
						newestcrashdate = date;
						path = fullPath;
					}
				}
			}
		}

		if (path)
		{
			NSDate *lastCrashDate = [[NSUserDefaults standardUserDefaults] objectForKey:kLastCrashDateKey];
			if (!lastCrashDate)
				lastCrashDate = [NSDate distantPast];

			if ([(NSDate *)[[[NSFileManager defaultManager] attributesOfItemAtPath:path error:NULL] objectForKey:@"NSFileModificationDate"] compare:lastCrashDate] == NSOrderedDescending)
			{
                NSData *data = [NSData dataWithContentsOfFile:path];
				NSString *crashlogsource = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
				NSString *crashlog = [[[[crashlogsource componentsSeparatedByString:@"**********"] lastObject] componentsSeparatedByString:@"Binary Images:"] objectAtIndex:0];

				NSString *machinetype = [JMHostInformation machineType];
				BOOL foundNeccessaryString = FALSE;


				if (!neccessaryStrings)
					foundNeccessaryString = TRUE;
				else
				{
					for (NSString *ns in neccessaryStrings)
						if ([crashlog rangeOfString:ns].location != NSNotFound)
							foundNeccessaryString = TRUE;
				}

				if (!foundNeccessaryString)
				{
#if ! __has_feature(objc_arc)
					[crashlogsource release];
#endif
					return;
				}

                
				NSInteger code = alert([cc.appName stringByAppendingString:@" Crash Report"],
												 [NSString stringWithFormat:NSLocalizedString(@"It seems like %@ has crashed recently. Please consider sending the crash-log to help fix this problem. Also make sure you are using the latest version by using the built-in update mechanism since most reported crashes are already fixed in the latest version.", nil), cc.appName],
												 NSLocalizedString(@"Send", nil), NSLocalizedString(@"Never", nil), NSLocalizedString(@"Cancel", nil));

				[[NSUserDefaults standardUserDefaults] setObject:[NSDate dateWithTimeIntervalSinceNow:60 * 60 * 24 * 3] forKey:kLastCrashDateKey]; // bug the user every 3 days at most

				if (code == NSAlertFirstButtonReturn)
				{
					NSMutableString *inputManagers = [NSMutableString string];
					NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSAllDomainsMask, YES);
					for (NSString *libPath in paths)
					{
						NSArray *inputManagerArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[libPath stringByAppendingPathComponent:@"/InputManagers/"] error:NULL];
						for (NSString *inputManager in inputManagerArray)
							if (![inputManager isEqualToString:@".DS_Store"])
								[inputManagers appendFormat:@" %@ ", inputManager];
					}

					NSString *subject = [NSString stringWithFormat:@"%@ Crashreport", cc.appName];
					NSString *body = [NSString stringWithFormat:@"Unfortunately %@ has crashed!\n\n--%@--\n\n\nMachine Type: %@\nInput Managers: %@\n\nCrash Log (%d):\n\n**********\n%@\nUser Defaults:\n\n**********\n%@", cc.appName, NSLocalizedString(@"Please fill in additional details here", nil), machinetype, inputManagers, cc.appBuildNumber, crashlog, [[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] description]];


					NSString *mailtoLink = [NSString stringWithFormat:@"mailto:%@?subject=%@&body=%@", email, subject, body];
					CFStringRef urlstring = CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)mailtoLink, NULL, NULL, kCFStringEncodingUTF8);
					NSURL *url = [NSURL URLWithString:(__bridge NSString *)urlstring];

					CFRelease(urlstring);
					if (![[NSWorkspace sharedWorkspace] openURL:url])
						asl_NSLog(ASL_LEVEL_WARNING, @"Warning: %@ was unable to open the URL.", cc.appName);

				}
				else if (code == NSAlertSecondButtonReturn)
					[[NSUserDefaults standardUserDefaults] setInteger:1 forKey:kNeverCheckCrashesKey];

				if (![[NSUserDefaultsController sharedUserDefaultsController] commitEditing])
					asl_NSLog(ASL_LEVEL_WARNING, @"Warning: shared user defaults controller could not commit editing");

#if ! __has_feature(objc_arc)
				[crashlogsource release]; 
#endif
			}
		}
	}
}
