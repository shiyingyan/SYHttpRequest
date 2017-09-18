//
//  TableViewController.m
//  hq
//
//  Created by shiying on 17/09/2017.
//  Copyright © 2017 Data Enlighten. All rights reserved.
//

#import "TableViewController.h"
#import "FViewController.h"

@interface TableViewController ()

@property (nonatomic,strong) NSMutableArray *dataList;

@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
#warning please set your phone
    NSString *phone = @"";
    _dataList = [NSMutableArray arrayWithArray:@[@{@"text":@"sample1",
                                                   @"url":[@"https://www.baifubao.com/callback?cmd=1059&callback=phone&phone=" stringByAppendingString:phone]}]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];
    
    cell.textLabel.text = _dataList[indexPath.row][@"text"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FViewController *f = [FViewController new];
    f.url = _dataList[indexPath.row][@"url"];
    [self.navigationController showViewController:f sender:nil];
}

@end
