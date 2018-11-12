//
//  ViewController.m
//  ZCrashSaftey
//
//  Created by icharge on 2018/11/12.
//  Copyright © 2018年 icharge. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  [self crashTesting];
}
- (void)crashTesting
{
    NSString *str = nil;
    NSArray *arr1 = @[@"1",@"2",str];
    NSLog(@"%@",arr1);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
