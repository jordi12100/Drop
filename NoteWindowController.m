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

- (void)windowDidLoad {
    [super windowDidLoad];
    [[self window] setLevel:NSFloatingWindowLevel];
    
    [noteMessage setAutomaticQuoteSubstitutionEnabled:NO];
    [noteMessage setEnabledTextCheckingTypes:0];
}

- (IBAction)uploadNoteAction:(id)sender {
    [Request createGistWithTitle:[noteTitle stringValue] andDescription:[[noteMessage textStorage] string]
        success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSString *response = [responseObject objectForKey:@"html_url"];
            [AppDelegate sendNotificationWithMessage:response];
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@", error);
        }
     ];
}

- (IBAction)cancelAction:(id)sender {
    [self close];
}

@end
