//
//  NoteWindowController.h
//  Drop
//
//  Created by Jordi Kroon on 26/01/15.
//  Copyright (c) 2015 Jordi Kroon. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Request.h"
#import "AppDelegate.h"

@interface NoteWindowController : NSWindowController

@property (strong) IBOutlet NSTextField *noteTitle;
@property (strong) IBOutlet NSTextView *noteMessage;

@end
