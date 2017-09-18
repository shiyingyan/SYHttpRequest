//
//  RootViewController.m
//  hq
//
//  Created by shiying on 17/09/2017.
//  Copyright © 2017 Data Enlighten. All rights reserved.
//

#import "RootViewController.h"
@interface RootViewController ()

@end

@implementation RootViewController

- (void)dealloc {
    [[SYHttpRequest sharedInstance] cancelAFSesstionTasksForControllerHash:self.hash];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if( !_textView ) {
        _textView = [[UITextView alloc] initWithFrame:CGRectZero];
        _textView.editable = NO;
        [self.view addSubview:_textView];
        _textView.frame = self.view.bounds;
        _textView.font = [UIFont systemFontOfSize:20 weight:10];
    }

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
