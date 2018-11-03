//
//  FViewController.m
//  hq
//
//  Created by Shing on 17/09/2017.
//  Copyright © 2017 Data Enlighten. All rights reserved.
//

#import "FViewController.h"

@interface FViewController ()


@end

@implementation FViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
