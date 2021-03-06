//
//  NoteWindowController.m
//  Drop
//
//  Created by Jordi Kroon on 26/01/15.
//  Copyright (c) 2015 Jordi Kroon. All rights reserved.
//

#import "NoteWindowController.h"
#import "SystemStorage.h"

@interface NoteWindowController ()

@end

@implementation NoteWindowController

@synthesize noteMessage;
@synthesize noteTitle;

/**
 *  On load window
 */
- (void)windowDidLoad {
    [super windowDidLoad];
    [[self window] setLevel:NSFloatingWindowLevel];
    [[self window] makeKeyAndOrderFront:self];
    
    [noteMessage setAutomaticQuoteSubstitutionEnabled:NO];
    [noteMessage setEnabledTextCheckingTypes:0];
}

/**
 * On show window
 */
- (void)awakeFromNib {
    [[self window] makeFirstResponder:noteMessage];
}

/**
 *  Upload note action
 *
 *  @param sender
 */
- (IBAction)uploadNoteAction:(id)sender {
    [SystemStorage wipeClipboard];
    
    AppDelegate* appDelegate = (AppDelegate*)[[NSApplication sharedApplication] delegate];
    [appDelegate startAnimating];
    
    [Request createGistWithTitle:[noteTitle stringValue] andDescription:[[noteMessage textStorage] string]
        success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSString *response = [responseObject objectForKey:@"html_url"];
            [appDelegate sendNotificationWithMessage:response];
            [appDelegate stopAnimating];
            
            [SystemStorage addMessageToClipboard: response];
            
            [self cancelAction:self];
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [appDelegate sendNotificationWithMessage:[error description]];
            [appDelegate stopAnimating];
            [self cancelAction:self];
        }
     ];
}

/**
 *  Cancel button
 *
 *  @param sender
 */
- (IBAction)cancelAction:(id)sender {
    [self close];
}

@end
