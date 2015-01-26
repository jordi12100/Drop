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

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification{
    return YES;
}

- (void)initEventShortCuts {
    [NSEvent addGlobalMonitorForEventsMatchingMask:NSKeyDownMask handler: ^(NSEvent *event) {
        NSUInteger flags = [event modifierFlags] & NSDeviceIndependentModifierFlagsMask;
        if (flags == NSAlternateKeyMask + NSShiftKeyMask) {
            
            if ([event keyCode] == 32) {
                [self uploadScreenshotAction:self];
            }
            
            if ([event keyCode] == 8) {
                [self saveScreenshotToClipboardAction:self];
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
    
    [menuItemUpload setKeyEquivalentModifierMask: NSShiftKeyMask | NSAlternateKeyMask];
    [menu addItem:menuItemUpload];
    
    //Clipboard
    NSMenuItem *menuItemClipboard = [[NSMenuItem alloc] initWithTitle:@"Copy to clipboard"
                                                               action:@selector(saveScreenshotToClipboardAction:)
                                                        keyEquivalent:@"C"
                                     ];
    
    [menuItemClipboard setKeyEquivalentModifierMask: NSShiftKeyMask | NSAlternateKeyMask];
    
    [menu addItem:menuItemClipboard];
    [menu addItem:[NSMenuItem separatorItem]];
    
    [menu addItemWithTitle:@"Test" action:@selector(composeNoteAction:) keyEquivalent:@""];
    
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
    
    [screenshot generateScreenshot];
    [self startAnimating];
    Request *request = [[Request alloc] init];
    
    [request uploadFileFromLocation:[screenshot getOutputFile]
        success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSString *response = [responseObject objectAtIndex:0];
            NSLog(@"%@", response);
            [SystemStorage addMessageToClipboard: response];
            
            [self stopAnimating];
            [AppDelegate sendNotificationWithMessage: response];
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@", error);
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
    [screenshot generateScreenshot];
    
    [AppDelegate sendNotificationWithMessage: @"Image copied to clipboard"];
}

/**
 *  Display a notification in the top right corner
 *
 *  @param message description
 */
+ (void) sendNotificationWithMessage: (NSString *)message {
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = @"Drop";
    notification.informativeText = (NSString *)message;
    notification.soundName = NSUserNotificationDefaultSoundName;
    
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
}

/**
 *  On click notification
 *
 *  @param center       <#center description#>
 *  @param notification <#notification description#>
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
