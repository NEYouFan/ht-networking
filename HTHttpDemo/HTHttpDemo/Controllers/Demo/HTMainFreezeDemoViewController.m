//
//  HTMainFreezeDemoViewController.m
//  HTHttpDemo
//
//  Created by Wangliping on 16/2/4.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "HTMainFreezeDemoViewController.h"
#import "HTFreezeDemoViewController.h"
#import "HTRKFreezeDemoViewController.h"

@interface HTMainFreezeDemoViewController ()

@end

@implementation HTMainFreezeDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = @"Freeze Request Demo";
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

#pragma mark - Load Data

- (NSArray *)generateMethodNameList {
    return @[@"demoFreezeRequestWithRKMananger",
             @"demoFreezeRequestWithHTBaseRequest"];
}

#pragma mark - Test Methods

- (void)demoFreezeRequestWithRKMananger {
    HTFreezeDemoViewController *vc = [[HTFreezeDemoViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)demoFreezeRequestWithHTBaseRequest {
    HTRKFreezeDemoViewController *vc = [[HTRKFreezeDemoViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
