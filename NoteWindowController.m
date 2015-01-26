//
//  NoteWindowController.m
//  Drop
//
//  Created by Jordi Kroon on 26/01/15.
//  Copyright (c) 2015 Jordi Kroon. All rights reserved.
//

#import "NoteWindowController.h"

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
    
    [noteMessage setAutomaticQuoteSubstitutionEnabled:NO];
    [noteMessage setEnabledTextCheckingTypes:0];
}

/**
 *  Upload note action
 *
 *  @param sender
 */
- (IBAction)uploadNoteAction:(id)sender {
    AppDelegate* appDelegate = (AppDelegate*)[[NSApplication sharedApplication] delegate];
    
    [appDelegate startAnimating];
    [Request createGistWithTitle:[noteTitle stringValue] andDescription:[[noteMessage textStorage] string]
        success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSString *response = [responseObject objectForKey:@"html_url"];
            [appDelegate sendNotificationWithMessage:response];
            [appDelegate stopAnimating];
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
