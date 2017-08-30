//
//  ViewController.m
//  OptimizationUITbaleView
//
//  Created by XueShan Zhang on 2017/8/29.
//  Copyright © 2017年 XueShan Zhang. All rights reserved.
//

#import "ViewController.h"

#import "OptimizationTableView.h"

@interface ViewController (){
    OptimizationTableView *tableView;
}


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    //2.NSValue可以包装任意一个对象，包括系统自定义的数据结构，结构体等等
    
    //3.NSNumber是NSValue的一个子类
    
    //NSValue
    NSValue *pointValue = [NSValue  valueWithCGRect:CGRectMake(0, 0, 200, 30)];
    [pointValue  CGRectValue];
    
    //NSLog(@"pointValue  == %@",pointValue);
    //NSLog(@"pointValue  CGRectValue == %f",[pointValue  CGRectValue].size.height);

    tableView = [[OptimizationTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
    tableView.scrollIndicatorInsets = tableView.contentInset;
    [self.view addSubview:tableView];
    
    UIToolbar *statusBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20)];
    [self.view addSubview:statusBar];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end





