//
//  Request.m
//  Drop
//
//  Created by Jordi Kroon on 25/01/15.
//  Copyright (c) 2015 Jordi Kroon. All rights reserved.
//

#import "Request.h"

@implementation Request

/**
 *  remote upload path
 */
NSString *const CT_RemoteUploadPath = @"http://domain.tld/upload";

/**
 *  Gist access token
 */
NSString *const CT_GistAccessToken = @"TOKEN_HERE";

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

/**
 *  Send request to github to create a new gist
 *
 *  @param title
 *  @param description
 *  @param success
 *  @param failure
 */
+ (void)createGistWithTitle: (NSString *)title andDescription: (NSString *)description
                    success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    
    
    NSString *GithubUrl = [NSString stringWithFormat:@"https://api.github.com/gists?access_token=%@", CT_GistAccessToken];
    NSURL *url = [NSURL URLWithString:GithubUrl];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData  timeoutInterval:10];
    
    [request setHTTPMethod:@"POST"];
    [request setValue: @"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSDictionary *jsonDictionary = @{
        @"description" : title,
        @"public" : @NO,
        @"files" : @{
            title : @{
                @"content" : description
            },
        }
    };
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary
                                            options:NSJSONWritingPrettyPrinted
                                            error:nil];
    
    [request setHTTPBody: jsonData];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(nil, responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(nil, error);
        
    }];
    [op start];
}
@end
