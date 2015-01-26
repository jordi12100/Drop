//
//  Screenshot.h
//  Drop
//
//  Created by Jordi Kroon on 25/01/15.
//  Copyright (c) 2015 Jordi Kroon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Screenshot : NSObject

@property (strong, nonatomic, getter=getSavePath) NSString* savePath;

- (BOOL)generateScreenshot;
- (NSString *)getOutputFile;

@end
