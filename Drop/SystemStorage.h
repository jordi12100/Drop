//
//  SystemStorage.h
//  Drop
//
//  Created by Jordi Kroon on 25/01/15.
//  Copyright (c) 2015 Jordi Kroon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SystemStorage : NSObject

+ (NSString *)findResourcePath;
+ (void)addMessageToClipboard: (NSString *)message;
+ (void)wipeClipboard;
+ (NSString *)getLastClipboardString;
@end
