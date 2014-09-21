//
//  QBaseRequest.m
//  QBaseFramework
//
//  Created by andy on 9/20/14.
//  Copyright (c) 2014 streakq. All rights reserved.
//

#import "QBaseRequest.h"

@implementation QBaseRequest
DEFINE_SINGLETON_FOR_CLASS(QBaseRequest)

+ (void)registRequest:(QBaseRegistBlock)registBlock
{
    registBlock([QBaseRequest sharedQBaseRequest]);
}

+ (void)GET:(NSString *)url params:(NSDictionary *)params complete:(QBaseRequestCompleteBlock)completeBlock
{
    [[AFHTTPRequestOperationManager manager] GET:url
                                      parameters:params
                                         success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                             
                                             completeBlock(responseObject, nil);
                                         }
                                         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             
                                             completeBlock(nil, error);
                                         }];
}

+ (void)POST:(NSString *)url params:(NSDictionary *)params complete:(QBaseRequestCompleteBlock)completeBlock
{
    [[AFHTTPRequestOperationManager manager] POST:url
                                       parameters:params
                                          success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                              
                                              completeBlock(responseObject, nil);
                                          }
                                          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                              
                                              completeBlock(nil, error);
                                          }];
}

+ (void)POST:(NSString *)url params:(NSDictionary *)params body:(QBaseRequestBodyBlock)bodyBlock complete:(QBaseRequestCompleteBlock)completeBlock
{
    [[AFHTTPRequestOperationManager manager] POST:url
                                       parameters:params
                        constructingBodyWithBlock:bodyBlock
                                          success:^(AFHTTPRequestOperation *operation, id responseObject) {

                                              completeBlock(responseObject, nil);
                                          }
                                          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
                                              completeBlock(nil, error);
                                          }];
}

@end
