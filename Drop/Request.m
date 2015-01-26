//
//  Request.m
//  Drop
//
//  Created by Jordi Kroon on 25/01/15.
//  Copyright (c) 2015 Jordi Kroon. All rights reserved.
//

#import "Request.h"
#import "OctoKit.h"

@implementation Request

/**
 *  remote upload path
 */
NSString *const CT_RemoteUploadPath = @"http://drop.ghservers.org/index.php";

/**
 *  Github request URL
 */
NSString *const CT_GithubGistUrl = @"https://api.github.com/gists?access_token=8b4088bc9d1b0b55f0772be88480ea1ed931e379";

/**
 *  AF Request decorator to send files to the remote server
 *
 *  @param location
 *  @param success
 *  @param failure
 */
- (void)uploadFileFromLocation:(NSString *)location
                         success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:CT_RemoteUploadPath parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileURL:[NSURL fileURLWithPath:location] name:@"userfile" error:nil];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(nil, responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(nil, error);
    }];
}

+ (void)createGistWithTitle: (NSString *)title andDescription: (NSString *)description {
    
    OCTClient *client = [OCTClient unauthenticatedClientWithUser:user];
    
    //NSLog(@"id :%@", [newGist gistId]);
}
@end
