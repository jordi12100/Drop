//
//  Screenshot.m
//  Drop
//
//  Created by Jordi Kroon on 25/01/15.
//  Copyright (c) 2015 Jordi Kroon. All rights reserved.
//

#import "Screenshot.h"
#import "SystemStorage.h"

@implementation Screenshot

/**
 *  path to save screenshot in storage
 */
NSString *const CT_LocalFileName = @"tmp_capture.png";

/**
 *  generates the screenshot
 */
- (BOOL)generateScreenshot {
    [SystemStorage wipeClipboard];
    [[NSFileManager defaultManager] removeItemAtPath:[self getOutputFile] error:NULL];

    NSPipe *pipe = [NSPipe pipe];
    NSFileHandle *file = pipe.fileHandleForReading;

    NSTask *task = [[NSTask alloc] init];

    task.launchPath = @"/usr/sbin/screencapture";
    task.standardOutput = pipe;
    
    task.arguments = @[@"-ci"];
    BOOL isUpload = NO;
    if ([self getSavePath] != nil) {
        task.arguments = @[@"-i", [self getOutputFile]];
        isUpload = YES;
    }

    [task launch];
    
    // Just a way to do this without a block
    [file readDataToEndOfFile];
    [file closeFile];
    
    if (!isUpload) {
        return ![[SystemStorage getLastClipboardString] isEqualToString: @""];
    } else {
        return [[NSFileManager defaultManager] fileExistsAtPath:[self getOutputFile]];
    }
    
    return NO;
}

/**
 *  returns the full path of the image
 *
 *  @return string
 */
- (NSString *)getOutputFile {
    return [NSString stringWithFormat:@"%@/%@", [self getSavePath], CT_LocalFileName];
}

@end
