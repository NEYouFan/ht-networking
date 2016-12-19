//
//  HTHttpTableViewController.m
//  HTHttpDemo
//
//  Created by Wang Liping on 15/9/17.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "HTHttpTableViewController.h"
#import "UITableView+HTHTTPDemo.h"

static NSString * const  kUICellIdentifier = @"UICellIdentifier";

@interface HTHttpTableViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *methodsNameList;

@end

@implementation HTHttpTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self loadTableView];
    [self loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadTableView
{
    self.tableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kUICellIdentifier];
    [self.view addSubview:self.tableView];
    
    CGFloat bottomSpace = (nil == self.tabBarController.tabBar || self.tabBarController.tabBar.hidden ? 0 : 49);
    [self.tableView ht_DemoConfigViewTop:nil bottom:nil leading:nil trailing:nil constants:@[@(0), @(-bottomSpace), @(0), @(0)]];
}

- (void)loadData {
    self.methodsNameList = [NSArray arrayWithArray:[self generateMethodNameList]];
}

- (NSArray *)generateMethodNameList {
    return nil;
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.methodsNameList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdenfier = @"TestCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdenfier];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdenfier];
    }
    
    cell.textLabel.text = [self.methodsNameList objectAtIndex:indexPath.row];
    
    return cell;
}

// 隐藏GroupedTable的默认Footer. 同理可以隐藏默认Header.
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0001;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *methodName = [self.methodsNameList objectAtIndex:indexPath.row];
    if ([methodName length] > 0) {
        SEL method = NSSelectorFromString(methodName);
        if ([self respondsToSelector:method]) {
            [self performSelector:method];
        }
    }
}

@end
