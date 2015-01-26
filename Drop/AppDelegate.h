//
//  AppDelegate.h
//  Drop
//
//  Created by Jordi Kroon on 25/01/15.
//  Copyright (c) 2015 Jordi Kroon. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NoteWindowController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, NSUserNotificationCenterDelegate>

@property (strong, nonatomic) NSStatusItem *statusItem;
@property (strong, nonatomic) NSTimer *animTimer;

@property (weak) IBOutlet NSWindow *window;
@property (readwrite, nonatomic) int currentFrame;

@property (strong, nonatomic) NoteWindowController *noteWindowController;

@end

