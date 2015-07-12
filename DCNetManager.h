

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperationManager.h"
//调度AFNetWorking请求
//请求成功block
typedef void (^AFFinishedBlock)(AFHTTPRequestOperation* oper,id responseObj);
//请求失败block
typedef void (^AFFailedBlock)(AFHTTPRequestOperation* oper,NSError * error);
@interface DCNetManager : NSObject
//通过对外暴漏类方法 (不用实例化对象)
+(void)requestWithUrlString:(NSString*)urlString WithDiction:(NSMutableDictionary*)postDic finished:(AFFinishedBlock)finishedBlock failed:(AFFailedBlock)failedBlcok;
@end

















