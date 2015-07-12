//
//  RegisterObject.m
//  Food
//
//  Created by mac on 15/7/9.
//  Copyright (c) 2015年 MAC. All rights reserved.
//

#import "RegisterObject.h"
#import "DCNetManager.h"
static NSString *const smsUrl = @"http://i.dzdache.com/pinche/sms";

@interface RegisterObject()
@end

@implementation RegisterObject
+ (void)RegisterNewUserWithUserPhone:(NSString *)userPhone andUserPassword:(NSString *)passwordStr andInvitationCode:(NSString *)invitationCodeStr complete:(registerResponse)complete{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:@"0006" forKey:@"actioncode"];
    [dic setObject:userPhone forKey:@"phone"];
    [dic setValue:@"1.0" forKey:@"protocol"];
    [dic setValue:@"2" forKey:@"terminaltype"];
    [dic setValue:@"dz001" forKey:@"channel"];
    [dic setValue:@"0" forKey:@"flag"];
    [dic setValue:@"29e57a55107018587adfb98b5aec3a40" forKey:@"sign"];
    [dic setValue:@"12334" forKey:@"imei"];
    [dic setValue:@"1" forKey:@"type"];
    [dic setValue:@"0" forKey:@"flag"];

    [DCNetManager requestWithUrlString:smsUrl WithDiction:dic finished:^(AFHTTPRequestOperation *oper, id responseObj) {
        NSData *data = (NSData *)responseObj;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSUTF8StringEncoding error:nil];
        complete(dic);
    } failed:^(AFHTTPRequestOperation *oper, NSError *error) {
        NSLog(@"register error:%@", error.description);
    }];
}
+ (void)RequestCodeWithActionCode:(NSString *)actioncode  andUserPhone:(NSString *)userphone complete:(registerResponse)complete{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:@"0006" forKey:@"actioncode"];
    [dic setObject:userphone forKey:@"phone"];
    [dic setValue:@"1.0" forKey:@"protocol"];
    [dic setValue:@"2" forKey:@"terminaltype"];
    [dic setValue:@"dz001" forKey:@"channel"];
    [dic setValue:@"0" forKey:@"flag"];
    [dic setValue:@"29e57a55107018587adfb98b5aec3a40" forKey:@"sign"];
    [dic setValue:@"12334" forKey:@"imei"];
    [dic setValue:@"1" forKey:@"type"];
    [dic setValue:@"0" forKey:@"flag"];
    [DCNetManager requestWithUrlString:smsUrl WithDiction:dic finished:^(AFHTTPRequestOperation *oper, id responseObj) {
        if (responseObj) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:(NSData*)responseObj options:NSUTF8StringEncoding error:nil];
            complete(dic);
            NSLog(@"dic:%@",dic);
        }
    } failed:^(AFHTTPRequestOperation *oper, NSError *error) {
        NSLog(@"register code error:%@",error.description);
    }];

}
@end

























