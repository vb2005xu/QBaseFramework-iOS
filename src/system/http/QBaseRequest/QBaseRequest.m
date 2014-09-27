//
//  QBaseRequest.m
//  QBaseFramework
//
//  Created by andy on 9/20/14.
//  Copyright (c) 2014 streakq. All rights reserved.
//

#import "QBaseRequest.h"

@implementation QBaseRequest

- (void)GET:(NSString *)url params:(NSDictionary *)params complete:(QBaseRequestCompleteBlock)completeBlock
{
    [self GET:url
   parameters:params
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          completeBlock(responseObject, nil);
      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         completeBlock(nil, error);
     }];
}

- (void)POST:(NSString *)url params:(NSDictionary *)params complete:(QBaseRequestCompleteBlock)completeBlock
{
    [self POST:url
    parameters:params
       success:^(AFHTTPRequestOperation *operation, id responseObject) {
           completeBlock(responseObject, nil);
      }
       failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          completeBlock(nil, error);
       }];
}

- (void)POST:(NSString *)url params:(NSDictionary *)params body:(QBaseRequestBodyBlock)bodyBlock complete:(QBaseRequestCompleteBlock)completeBlock
{
    [self POST:url
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
