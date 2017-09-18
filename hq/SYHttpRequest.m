//
//  SYHttpRequest
//  hq
//  Created by shiying on 5/10/16.
//  Copyright © 2016 Cstorm. All rights reserved.
//

#import "SYHttpRequest.h"

@interface SYHttpRequest ()

//网络数据请求任务集合
@property (nonatomic,strong) NSMutableArray *AFUrlSessionTasks;

//自定义线程池
@property (nonatomic,strong) NSOperationQueue *operationQueue;

//管理某个特定的controlelr的网络请求任务
@property (nonatomic,strong) NSMutableDictionary *controllerTasks;

@end

@implementation SYHttpRequest

+ (SYHttpRequest *_Nonnull)sharedInstance {
    static SYHttpRequest *httpRequest = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        httpRequest = [[[self class] alloc] init];
    });
    return httpRequest;
}

-(NSURLSessionTask *_Nullable)sendRequestToServerWithMethod:(NSString *)method
                                                        url:(NSString *)urlString
                                              authorization:(NSString * _Nullable)authorization
                                                 parameters:(id)parameters
                                                 completion:(_Nullable ServiceResponseBlock)completion{
    return [self sessionTaskWithMethod:method
                                   url:urlString
                         authorization:authorization
                            parameters:parameters
                        uploadProgress:nil
                      downloadProgress:nil
                            completion:completion];
}
-(NSURLSessionTask *_Nullable)sendRequestToServerWithMethod:(NSString *)method
                                                        url:(NSString *)urlString
                                              authorization:(NSString * _Nullable)authorization
                                                 parameters:(id)parameters
                                             uploadProgress:(void (^)(NSProgress * _Nullable))uploadProgressBlock
                                           downloadProgress:(void (^)(NSProgress * _Nullable))downloadProgressBlock
                                                 completion:(_Nullable ServiceResponseBlock)completion{
    return [self sessionTaskWithMethod:method
                                   url:urlString
                         authorization:authorization
                            parameters:parameters
                        uploadProgress:uploadProgressBlock
                      downloadProgress:downloadProgressBlock
                            completion:completion];
}

-(NSURLSessionTask *_Nullable)sessionTaskWithMethod:(NSString *)method
                                                url:(NSString *)urlString
                                      authorization:(NSString * _Nullable)authorization
                                         parameters:(id)parameters
                                     uploadProgress:(void (^)(NSProgress * _Nullable))uploadProgressBlock
                                   downloadProgress:(void (^)(NSProgress * _Nullable))downloadProgressBlock
                                         completion:(_Nullable ServiceResponseBlock)completion{
    if( ![self.class networkReachibility] ){
        if( completion ) completion(nil,NO,[NSError errorWithDomain:@"Network can`t be connected" code:5000 userInfo:nil]);
        return nil;
    }
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    

    
    AFJSONRequestSerializer *s = [AFJSONRequestSerializer serializer];
    NSMutableURLRequest *urlRequest = [s requestWithMethod:method URLString:urlString parameters:parameters error:nil];
    
    urlRequest.timeoutInterval = 15;
    NSLog(@"request.url = %@",urlRequest.URL.absoluteString);
    if( [method isEqualToString:@"POST"] ){
        NSLog(@"request.httpbody = %@",[[NSString alloc] initWithData:urlRequest.HTTPBody encoding:NSUTF8StringEncoding]);
    }
    
    if( authorization && authorization.length ) {
        [urlRequest addValue:authorization forHTTPHeaderField:@"Authorization"];
    }
    
    
    NSURLSessionTask *sessionTask = [self.httpSessionManager dataTaskWithRequest:urlRequest
                                                                  uploadProgress:uploadProgressBlock
                                                                downloadProgress:downloadProgressBlock
                                                               completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error)
                                     {
                                         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                         
                                         if( error ){
                                             
                                             NSLog(@">>>>url = %@\nerror +%@\nreponseObject = %@",urlString,error,responseObject);
                                             NSLog(@"reponseObject.allValues = %@",[responseObject allValues]);
                                             if( error.code == -999 ){  //任务被取消,则不弹出警告框
                                                 
                                                 
                                             }else if( error.code == -1001 ){  //连接超时
                                                 
                                                 
                                             }else if( error.code == -1005 ) { //未联网
                                                 
                                                 
                                             }else{
                                                 //自定义提示消息
                                                 
                                             }
                                             
                                             if( completion ) completion(responseObject,NO,error);
                                             
                                         }else{
                                             
                                             //响应无错误情况
                                             if( completion ) completion(responseObject,YES,nil);
                                             
                                         }
                                     }];
    
    [sessionTask resume];
    sessionTask.taskDescription = urlString;
    
    return sessionTask;
}


#pragma mark - lazy loading
-(AFHTTPSessionManager *)httpSessionManager{
    if( !_httpSessionManager ){
        _httpSessionManager = [AFHTTPSessionManager manager];
        
        AFHTTPResponseSerializer *s = [AFHTTPResponseSerializer serializer];
        s.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
        _httpSessionManager.responseSerializer = s;
    }
    return _httpSessionManager;
}

- (NSMutableDictionary *)controllerTasks {
    if( !_controllerTasks ) {
        _controllerTasks = [NSMutableDictionary dictionary];
    }
    return _controllerTasks;
}
#pragma mark - AF网络管理
- (void)registerAFSesstionTask:(NSURLSessionTask *)task forControllerHash:(NSUInteger)hash {
    [self registerAFSesstionTask:task forControllerHash:hash sameURLConcurrentInCurrentController:NO];
}
- (void)registerAFSesstionTask:(NSURLSessionTask * _Nullable)task forControllerHash:(NSUInteger)hash sameURLConcurrentInCurrentController:(BOOL)concurrent{
    if( task == nil ) return;
    
    NSNumber *key = [NSNumber numberWithUnsignedInteger:hash];
    
    NSMutableArray *sesstionTasks = [self.controllerTasks objectForKey:key];
    if( !sesstionTasks ) {
        sesstionTasks = [NSMutableArray array];
    }
    
    if( !concurrent ) {
        for (NSURLSessionTask *item in sesstionTasks) {
            if( [item.taskDescription isEqualToString:task.taskDescription] ) {
                return;
            }
        }
    }
    
    [sesstionTasks addObject:task];
    
    [self.controllerTasks setObject:sesstionTasks forKey:key];
}

- (void)cancelAFSesstionTasksForControllerHash:(NSUInteger)hash {
    
    NSNumber *key = [NSNumber numberWithUnsignedInteger:hash];
    
    NSMutableArray *controllerSessionTasks = [self.controllerTasks objectForKey:key];
    
    if( controllerSessionTasks==nil || controllerSessionTasks.count==0 ) return;
    
    for (int j=0; j<controllerSessionTasks.count; j++) {
        NSURLSessionTask *task = controllerSessionTasks[j];
        
        switch (task.state) {
            case NSURLSessionTaskStateCompleted:
            case NSURLSessionTaskStateSuspended:
            case NSURLSessionTaskStateRunning:
                [task cancel];
                break;
            default:
                break;
        }
        
        [controllerSessionTasks removeObject:task];
        j--;
    }
    
    [self.controllerTasks removeObjectForKey:key];
}

- (void)cancelAFSesstionTaskWithURLString:(NSString *)urlString {
    NSArray *keys = [self.controllerTasks allKeys];
    for (NSNumber *key in keys) {
        [self cancelAFSesstionTaskWithURLString:urlString forControllerHash:key.unsignedIntegerValue];
    }
}
- (void)cancelAFSesstionTaskWithURLString:(NSString *)urlString forControllerHash:(NSUInteger)hash {
    NSNumber *key = [NSNumber numberWithUnsignedInteger:hash];
    
    NSMutableArray *controllerSessionTasks = [self.controllerTasks objectForKey:key];
    
    if( controllerSessionTasks==nil || controllerSessionTasks.count==0 ) return;
    
    for (int j=0; j<controllerSessionTasks.count; j++) {
        NSURLSessionTask *task = controllerSessionTasks[j];
        if( [task.taskDescription isEqualToString:urlString] ) {
            [task cancel];
            [controllerSessionTasks removeObject:task];
            j--;
        }
    }
    
    if( controllerSessionTasks.count == 0 )
        [self.controllerTasks removeObjectForKey:key];
}

#pragma mark - 自定义线程管理
-(void)addCustomOperation:(NSOperation *)operation{
    [self.operationQueue addOperation:operation];
}
-(void)cancelCustomOperationWithNames:(NSArray *)names{
    if( names && names.count ){
        for (NSOperation *operation in  self.operationQueue.operations) {
            if( [names containsObject:operation.name] ){
                [operation cancel];
            }
        }
    }else{
        [self.operationQueue cancelAllOperations];
    }
}
-(NSOperationQueue *)operationQueue{
    if( !_operationQueue ){
        _operationQueue = [[NSOperationQueue alloc] init];
    }
    return _operationQueue;
}

-(void)dealloc{
    [self cancelCustomOperationWithNames:nil];
    //设置sesstion不可用
    [self.httpSessionManager invalidateSessionCancelingTasks:YES];
}

@end

@implementation SYHttpRequest (NetworkReachability)

//判断网络是否可用
+(BOOL)networkReachibility{
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    [manager startMonitoring];
    if( manager.networkReachabilityStatus==AFNetworkReachabilityStatusNotReachable ){
        NSLog(@"未联网");
        return NO;
    }
    return YES;
}

- (void)monitorNetworkWithStatusChangeBlock:(void (^)(AFNetworkReachabilityStatus status))statusChangeBlock {
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        statusChangeBlock(status);
    }];
}

- (void)startMonitorReachability {
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

- (void)stopMonitorReachability {
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
}

@end
