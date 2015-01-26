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
NSString *const CT_RemoteUploadPath = @"http://drop.ghservers.org/index.php";

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
@end
