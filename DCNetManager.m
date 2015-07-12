

#import "DCNetManager.h"
@implementation DCNetManager
+(void)requestWithUrlString:(NSString*)urlString WithDiction:(NSMutableDictionary*)postDic finished:(AFFinishedBlock)finishedBlock failed:(AFFailedBlock)failedBlcok
{
    AFHTTPRequestOperationManager* manager = [AFHTTPRequestOperationManager manager];
    //设置接收类型
    manager.responseSerializer=[AFHTTPResponseSerializer serializer];
    //申明请求的数据类型
    manager.requestSerializer=[AFJSONRequestSerializer serializer];
        //finished和failed的block是从上一步传递过来的
    [manager POST:urlString parameters:postDic success:finishedBlock failure:failedBlcok];
}

@end



















