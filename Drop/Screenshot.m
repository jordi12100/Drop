//
//  Screenshot.m
//  Drop
//
//  Created by Jordi Kroon on 25/01/15.
//  Copyright (c) 2015 Jordi Kroon. All rights reserved.
//

#import "Screenshot.h"

@implementation Screenshot

/**
 *  path to save screenshot in storage
 */
NSString *const CT_LocalFileName = @"tmp_capture.png";

/**
 *  generates the screenshot
 */
- (BOOL)generateScreenshot {
    [[NSFileManager defaultManager] removeItemAtPath:[self getOutputFile] error:NULL];
    
    NSPipe *pipe = [NSPipe pipe];
    NSFileHandle *file = pipe.fileHandleForReading;

    NSTask *task = [[NSTask alloc] init];

    task.launchPath = @"/usr/sbin/screencapture";
    task.standardOutput = pipe;
    
    task.arguments = @[@"-ci"];
    if ([self getSavePath] != nil) {
        task.arguments = @[@"-i", [self getOutputFile]];
    }

    [task launch];
    
    // Just a way to do this without a block
    [file readDataToEndOfFile];
    [file closeFile];
    
    return [[NSFileManager defaultManager] fileExistsAtPath:[self getOutputFile]];
    
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
