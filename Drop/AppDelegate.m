//
//  AppDelegate.m
//  Drop
//
//  Created by Jordi Kroon on 25/01/15.
//  Copyright (c) 2015 Jordi Kroon. All rights reserved.
//

#import "AppDelegate.h"
#import "Screenshot.h"
#import "SystemStorage.h"
#import "Request.h"

#import <ApplicationServices/ApplicationServices.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

@synthesize statusItem;
@synthesize currentFrame;
@synthesize animTimer;
@synthesize noteWindowController;

/**
 *  On app did finish launching
 *
 *  @param aNotification aNotification
 */
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
    
    [self initEventShortCuts];
    [self initStatusBar];
}

/**
 *  Present notification
 *
 *  @param center
 *  @param notification
 *
 *  @return bool
 */
- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification{
    return YES;
}

/**
 *  Handle shortkeys
 */
- (void)initEventShortCuts {
    NSDictionary *options = @{(__bridge id)kAXTrustedCheckOptionPrompt: @YES};
    if (!AXIsProcessTrustedWithOptions((__bridge CFDictionaryRef)options)) {
        return;
    }

    [NSEvent addGlobalMonitorForEventsMatchingMask:NSKeyDownMask handler: ^(NSEvent *event) {
        NSUInteger flags = [event modifierFlags] & NSDeviceIndependentModifierFlagsMask;
        if (flags == NSControlKeyMask + NSShiftKeyMask) {
            
            // Key: U
            if ([event keyCode] == 32) {
                [self uploadScreenshotAction:self];
            }
            
            // Key: C
            if ([event keyCode] == 8) {
                [self saveScreenshotToClipboardAction:self];
            }
            
            // Key: N
            if ([event keyCode] == 45) {
                [self uploadScreenshotAction:self];
            }
        }
    }];
}

/**
 *  Initializes status bar so it will appear in the top right bar
 */
- (void)initStatusBar {
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setMenu:[self getMenu]];
    [statusItem setHighlightMode:YES];
    
    NSImage* image = [NSImage imageNamed:@"default-icon"];
    [statusItem setImage:image];
}

/**
 *  Builds menu to appear in status bar
 *
 *  @return NSMenu list of menu items
 */
- (NSMenu *)getMenu {
    NSMenu *menu = [[NSMenu alloc] init];
    
    //Upload drop
    NSMenuItem *menuItemUpload = [[NSMenuItem alloc] initWithTitle:@"Upload drop"
                                                            action:@selector(uploadScreenshotAction:)
                                                     keyEquivalent:@"U"
                                  ];
    
    [menuItemUpload setKeyEquivalentModifierMask: NSShiftKeyMask | NSControlKeyMask];
    [menu addItem:menuItemUpload];
    
    //Clipboard
    NSMenuItem *menuItemClipboard = [[NSMenuItem alloc] initWithTitle:@"Copy to clipboard"
                                                               action:@selector(saveScreenshotToClipboardAction:)
                                                        keyEquivalent:@"C"
                                     ];
    
    [menuItemClipboard setKeyEquivalentModifierMask: NSShiftKeyMask | NSControlKeyMask];
    
    [menu addItem:menuItemClipboard];
    [menu addItem:[NSMenuItem separatorItem]];
    
    // Compose note
    NSMenuItem *menuItemNote = [[NSMenuItem alloc] initWithTitle:@"Compose note"
                                                               action:@selector(composeNoteAction:)
                                                        keyEquivalent:@"N"
                                     ];
    
    [menuItemNote setKeyEquivalentModifierMask: NSShiftKeyMask | NSControlKeyMask];
    
    [menu addItem:menuItemNote];
    [menu addItem:[NSMenuItem separatorItem]];
    [menu addItemWithTitle:@"Quit Drop" action:@selector(terminate:) keyEquivalent:@""];
    
    return menu;
}

/**
 *  Upload basic screenshot
 *
 *  @param sender
 */
- (void) composeNoteAction:(id)sender {
    noteWindowController = [[NoteWindowController alloc] initWithWindowNibName:@"NoteWindowController"];
    [noteWindowController showWindow:nil];
}

/**
 *  Upload basic screenshot
 *
 *  @param sender
 */
- (void) uploadScreenshotAction:(id)sender {
    Screenshot *screenshot = [[Screenshot alloc] init];
    [screenshot setSavePath:[SystemStorage findResourcePath]];
    
    if (![screenshot generateScreenshot]) {
        return;
    }
    
    [self startAnimating];
    Request *request = [[Request alloc] init];
    
    [request uploadFileFromLocation:[screenshot getOutputFile]
        success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSString *response = [responseObject objectAtIndex:0];
            [SystemStorage addMessageToClipboard: response];
            
            [self stopAnimating];
            [self sendNotificationWithMessage: response];
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self stopAnimating];
        }
     ];
}

/**
 *  Save screenshot to clipboard
 *
 *  @param sender
 */
- (void) saveScreenshotToClipboardAction:(id)sender {
    Screenshot *screenshot = [[Screenshot alloc] init];
    if ([screenshot generateScreenshot]) {
        [self sendNotificationWithMessage: @"Image copied to clipboard"];
    }
}

/**
 *  Display a notification in the top right corner
 *
 *  @param message description
 */
- (void) sendNotificationWithMessage: (NSString *)message {
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = @"Drop";
    notification.informativeText = (NSString *)message;
    notification.soundName = NSUserNotificationDefaultSoundName;
    
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
}

/**
 *  On click notification
 *
 *  @param center
 *  @param notification
 */
- (void) userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification
{
    NSString *notificationText = [notification informativeText];
    NSString *urlRegEx = @"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";
    
    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
    if ([urlTest evaluateWithObject:notificationText]) {
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:notificationText]];
    }
}

/**
 *  start animating the menu icon
 */
- (void)startAnimating
{
    currentFrame = 1;
    animTimer = [NSTimer scheduledTimerWithTimeInterval:5.0/30.0 target:self selector:@selector(updateImage:) userInfo:nil repeats:YES];
}

/**
 *  stop animating and reset the icon
 */
- (void)stopAnimating
{
    [animTimer invalidate];
    
    NSImage* image = [NSImage imageNamed:@"default-icon"];
    [statusItem setImage:image];
}

/**
 *  roll the icons
 *
 *  @param timer
 */
- (void)updateImage:(NSTimer*)timer
{
    if (currentFrame > 8) {
        currentFrame = 1;
    }
    
    NSImage* image = [NSImage imageNamed:[NSString stringWithFormat:@"loader_img%d",currentFrame]];
    [statusItem setImage:image];
    
    currentFrame++;
}

/**
 *  Terminate app, simulate CMD+Q
 */
- (void)terminate {
    [NSApp terminate:self];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
