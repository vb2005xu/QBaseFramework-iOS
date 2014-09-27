# NQUpdate

**NQUpdate是检测版本更新的开发组件**

### 准备工作:

1. 将src文件导入项目
2. 引入头文件NQUpdate.h

### 如何进行版本升级

**应用启动的时候进行检测版本更新**

```
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [NQUpdate logEnabled:YES];
    [NQUpdate registUpdateHandle:^(NSError *error, BOOL update, id result) {
        if (error) {
            NSLog(@"发生错误");
            return ;
        }
        
        NSLog(@"数据源: %@", result);
        
        if (update) {

        }else {

        }
        
    }];
    [NQUpdate startCheck];

	 ....
	 return YES;
}
```

**应用从桌面启动进入前台的时候进行检测**

```
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [NQUpdate startCheck];
}
```

**`注意事项:`** 默认若用户点击跳过, 则24小时内将不再提示版本更新

### API介绍

**开始版本检测,并且进行提示用户下载**

	+ (void)startCheck;

**当然,如果默认提供的服务要是不满足开发需求,可以自定义处理方式**

	+ (void)registUpdateHandle:(UpdateAppCompletionBlock)completionBlock;

**`UpdateAppCompletionBlock`参数介绍**

|     回调参数     |          代表内容          |
|---------------- | ------------------------ |
|  NSError *error | 请求服务器失败返回报错信息    |
|  BOOL update    | 用户是否点击Alert的升级     |
|  id result      | 请求服务器成功返回的相关信息  |


**打开查看运行日志**

	+ (void)logEnabled:(BOOL)isLog;

 