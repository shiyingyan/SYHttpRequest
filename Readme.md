### 介绍
- SYHttpRequest是对AFNetworking常用两个方法的二次封装,：GET/POST/
- 使用线程池，对任何网络操作的线程进行管理。不仅仅是AF的网络操作，也包含其他NSOperation创建的线程。
- 包含检查当前网络是否可用
-  发起网络操作时，状态栏自动会有状态显示。

### 初心
- 为应用中减少不必要的线程开销而生：controller关闭时，关闭当前controller中所有网络操作的线程，释放其占用的资源；
- 如果在创建任务时，未注册task， 则controller关闭时，此url占用的线程不会被释放。 

### 使用
GET / POST 两种请求方法都很简单。这里以GET为例：

```
    //调用网络操作
    __weak typeof(self)weakself = self;
    
    NSURLSessionTask *task = [[SYHttpRequest sharedInstance] sendRequestToServerWithMethod:@"GET"
                                                              url:_url
                                                    authorization:nil
                                                       parameters:nil
                                                       completion:^(id  _Nullable response, BOOL success, NSError * _Nullable error)
     {
         if( success ) {
             if( [response isKindOfClass:[NSData class]] ) {
                 weakself.textView.text = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
             }else{
                 NSLog(@"请确认响应信息数据类型");
             }
         }
     }];
    
    [[SYHttpRequest sharedInstance] registerAFSesstionTask:task forControllerHash:self.hash];


   //释放网络线程，两种方法
   //<1> 只需要在当前controller的dealloc方法中调用如下代码。
   //<2> 在基类RootController的dealloc方法中调用如下代码，前提是当前controller继承自RootController。（推荐此方法）
   [[SYHttpRequest sharedInstance] cancelAFSesstionTasksForControllerHash:self.hash]

```

##### SYHttpRequest是在2016年项目中使用需求，开始创建维护，一直在用。
##### 目前功能只有GET/POST方法，欢迎大家继续维护增加功能
