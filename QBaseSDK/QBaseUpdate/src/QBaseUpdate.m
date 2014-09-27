#import <UIKit/UIKit.h>
#import "QBaseUpdate.h"

// InfoDictionary -- Values
#define kCFBundleIdentifier ([[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"])
#define kCFBundleVersion ([[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"])
#define kUIDeviceFamily ([[[NSBundle mainBundle] infoDictionary] objectForKey:@"UIDeviceFamily"])

// UserDefault -- Values
#define REMIND_DATE @"REMIND_DATE"

// inline -- Func
CG_INLINE BOOL needUpdate(NSString *old, NSString *new) {
    return [old isEqualToString:new] ? NO : YES;
}
CG_INLINE BOOL needSkipUpdate() {
    return ([[NSUserDefaults standardUserDefaults] objectForKey:REMIND_DATE])?YES:NO;
}

// 打印
#define LOG(...)\
    if(SELF.logEnabled) \
        NSLog(__VA_ARGS__);
// SELF
#define SELF [QBaseUpdate shareManager]

@interface QBaseUpdate ()
@property (nonatomic, assign) BOOL logEnabled;
@property (nonatomic, strong) NSDictionary *dataDict;
@property (nonatomic, copy) UpdateAppCompletionBlock completionBlock;
@end

@implementation QBaseUpdate

+ (instancetype)shareManager
{
    static QBaseUpdate *_sharedInstance = nil;
    static dispatch_once_t onceToken ;
    
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[[self class] alloc] init];
    });
    
    return _sharedInstance;
}

/**
 *  是否打印运行状态 默认关闭
 *
 *  @param isLog 是否打开运行状态
 */
+ (void)logEnabled:(BOOL)isLog
{
    SELF.logEnabled = isLog;
}


/**
 *  检测版本回调
 *
 *  @param resultBlock 请求回调
 */
+ (void)registUpdateHandle:(UpdateAppCompletionBlock)completionBlock
{
    SELF.completionBlock = completionBlock;
}

/**
 *  版本检测
 */
+ (void)startCheck
{
    LOG(@"开始版本检测");
    
    if ([SELF checkConsecutiveDays]) {
        LOG(@"用户点击跳过忽略时间已到, 清除 REMIND_DATE");
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:REMIND_DATE];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    LOG(@"打开线程, 开始异步下载相关数据源, 相关链接为: %@", [SELF getUrl]);
    dispatch_queue_t queue = dispatch_queue_create(NULL, NULL);
    dispatch_async(queue, ^{
        
        NSError *error;
        
        NSData *data = [NSData dataWithContentsOfURL:[SELF getUrl]
                                      options:0
                                        error:&error];
        
        if (!data) {
            LOG(@"请求失败, 回调(错误, 无效, 无数据源), 结束");
            SELF.completionBlock(error, NO, nil);
            return ;
            
        }else {
            
            if (needSkipUpdate()) {
                LOG(@"距离上次用户点击取消不足%d秒, 结束",REMIND_INTERVAL);
                return;
            }
            
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data
                                                                   options:0
                                                                     error:nil];
            if (result && [result isKindOfClass:[NSDictionary class]]) {
                
                LOG(@"开始解析数据");
                
                SELF.dataDict = [result objectForKey:@"data"];
                
                if (!SELF.dataDict || ![SELF.dataDict isKindOfClass:[NSDictionary class]]) {
                    LOG(@"解析数据发现类型不匹配, 结束");
                    return;
                }
                
                // 去除服务器返回的v
                NSString *version = [SELF.dataDict objectForKey:@"version"];
                version = [version stringByReplacingOccurrencesOfString:@"v" withString:@""];
                
                if (needUpdate(kCFBundleVersion, version)) {

                    LOG(@"需要更新, 弹出提示框");

                    // 如果需要更新
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [SELF showUpdateAlert];
                    });
                    
                }else {
                    
                    LOG(@"不需要更新, 无需操作, 结束");
                    
                }
            }
        }
    });
}

/**
 *  展示更新提示框
 */
- (void)showUpdateAlert
{
    _alertView = [[UIAlertView alloc] initWithTitle:@"版本升级"
                                            message:[SELF.dataDict objectForKey:@"description"]
                                           delegate:self
                                  cancelButtonTitle:@"取消"
                                  otherButtonTitles:@"升级", nil];
    [_alertView show];
}

#pragma mark -
#pragma mark - getting

/**
 *  获取Url
 *
 *  @return 拼接完成的请求Url
 */
- (NSURL *)getUrl
{
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@", URL_CHECK_VERSION]];
}

/**
 *  获取当前设备可支持设备
 *
 *  @return 设备标示符 ( 0:iphone/ipad  1:iphone  2:ipad )
 */
- (int)getDeviceFamily
{
    NSArray *deviceFamily = kUIDeviceFamily;
    
    if (deviceFamily.count == 1)
        return [[deviceFamily lastObject] intValue];

    return 0;
}

/**
 *  检测用户点击取消的时间到当前时间的时间差是否超过设置的数值
 *
 *  @return YES(超过设置时间, 提示更新)  NO(没有超过设置时间, 不在提示更新)
 */
- (BOOL)checkConsecutiveDays
{
    NSDate *remindDate = [[NSUserDefaults standardUserDefaults] objectForKey:REMIND_DATE];
    
    if (remindDate == nil)
        return NO;

    NSDate *today = [NSDate date];
    
    NSInteger diff = abs([remindDate timeIntervalSinceDate:today]);
    
    return diff >= REMIND_INTERVAL;
}

#pragma mark -
#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        
        if (self.completionBlock) {
            _completionBlock(nil, NO, _dataDict);
        }

        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:REMIND_DATE];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        LOG(@"用户点击取消");
        
    }else if(buttonIndex == 1){

        if (self.completionBlock) {
            _completionBlock(nil, YES, _dataDict);
        }
        
        NSString *plistUrl = [NSString stringWithFormat:@"itms-services://?action=download-manifest&url=%@", [_dataDict objectForKey:@"plistUrl"]];
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:plistUrl]];

        LOG(@"用户点击升级");
    }
}

@end

