//
//  RegisterObject.h
//  Food
//
//  Created by mac on 15/7/9.
//  Copyright (c) 2015年 MAC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa.h>
typedef void (^registerResponse)(NSDictionary *dic);
@interface RegisterObject : NSObject
//注册
+ (void)RegisterNewUserWithUserPhone:(NSString *)userPhone andUserPassword:(NSString *)passwordStr andInvitationCode:(NSString *)invitationCodeStr complete:(registerResponse)complete;
////请求验证码
+ (void)RequestCodeWithActionCode:(NSString *)actioncode  andUserPhone:(NSString *)userphone complete:(registerResponse)complete;
@end
























