//
//  SystemStorage.m
//  Drop
//
//  Created by Jordi Kroon on 25/01/15.
//  Copyright (c) 2015 Jordi Kroon. All rights reserved.
//

#import "SystemStorage.h"
#import <AppKit/NSPasteboard.h>

@implementation SystemStorage

/**
 *  find path to application support
 *
 *  @return string
 */
+ (NSString *)findResourcePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *applicationSupportDirectory = [paths firstObject];

    NSString *path = [NSString stringWithFormat:@"%@/%@", applicationSupportDirectory, [[NSBundle mainBundle] bundleIdentifier]];
    
    NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:path
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:&error];
    if (error != nil) {
        NSLog(@"error creating directory: %@", error);
    }

    return path;
}

+ (void)addMessageToClipboard: (NSString *)message {
    [[NSPasteboard generalPasteboard] clearContents];
    [[NSPasteboard generalPasteboard] setString:message forType:NSPasteboardTypeString];
}
@end
