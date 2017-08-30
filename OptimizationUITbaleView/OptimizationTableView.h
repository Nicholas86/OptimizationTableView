//
//  OptimizationTableView.h
//  OptimizationUITbaleView
//
//  Created by XueShan Zhang on 2017/8/29.
//  Copyright © 2017年 XueShan Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OptimizationTableView : UITableView

@property(nonatomic,strong) NSMutableArray *datas;

@property(nonatomic,strong) NSMutableArray *needLoadArr;

@property(nonatomic,assign) BOOL scrollToToping;

@end
