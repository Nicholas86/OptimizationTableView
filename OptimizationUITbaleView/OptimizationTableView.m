//
//  OptimizationTableView.m
//  OptimizationUITbaleView
//
//  Created by XueShan Zhang on 2017/8/29.
//  Copyright © 2017年 XueShan Zhang. All rights reserved.
//

#import "OptimizationTableView.h"

#import "OptimizationTableViewCell.h"

#import "NSString+Additions.h"
#import "UIView+Additions.h"
#import "UIView+Additions.h"
#import "UIScreen+Additions.h"

@interface OptimizationTableView()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation OptimizationTableView

- (NSMutableArray *)datas{
    if (!_datas) {
        self.datas = [[NSMutableArray  alloc] init];
    }return _datas;
}

- (NSMutableArray *)needLoadArr{
    if (!_needLoadArr) {
        self.needLoadArr = [[NSMutableArray  alloc] init];
    }return _needLoadArr;
}


- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style{
    
    self = [super initWithFrame:frame style:style];
    
    if (self) {
        //self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.dataSource = self;
        self.delegate = self;
        [self  loadData];
        [self  reloadData];
    }return self;
    
}

#pragma mark UITableView

- (NSInteger)numberOfSections{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.datas.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    OptimizationTableViewCell *cell = (OptimizationTableViewCell *)[tableView  dequeueReusableCellWithIdentifier:@"cell"];
    
    if (cell == nil) {
    
        cell = [[OptimizationTableViewCell  alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    [self drawCell:cell withIndexPath:indexPath];

    return cell;
}

- (void)drawCell:(OptimizationTableViewCell *)cell withIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *data = [self.datas objectAtIndex:indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell clear];
    cell.data = data;
    if (self.needLoadArr.count>0&&[self.needLoadArr indexOfObject:indexPath]==NSNotFound) {
        [cell clear];
        return;
    }
    if (self.scrollToToping) {
        return;
    }
    [cell draw];
}

//行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *dict = self.datas[indexPath.row];
    float height = [dict[@"frame"] CGRectValue].size.height;
    return height;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSLog(@"单元格选中事件");

}


#pragma mark UIScrollView
//按需加载 - 如果目标行与当前行相差超过指定行数，只在目标滚动范围的前后指定3行加载。
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    
    NSLog(@" 按需加载 - 如果目标行与当前行相差超过指定行数，只在目标滚动范围的前后指定3行加载。");

    NSIndexPath *ip = [self indexPathForRowAtPoint:CGPointMake(0, targetContentOffset->y)];
    
    NSIndexPath *cip = [[self indexPathsForVisibleRows] firstObject];
    
    NSInteger skipCount = 8;
    
    if (labs(cip.row-ip.row) > skipCount) {
        
        NSArray *temp = [self indexPathsForRowsInRect:CGRectMake(0, targetContentOffset->y, self.width, self.height)];
        
        NSMutableArray *arr = [NSMutableArray arrayWithArray:temp];
        
        if (velocity.y<0) {
            
            NSIndexPath *indexPath = [temp lastObject];
            if (indexPath.row+3<self.datas.count) {
                [arr addObject:[NSIndexPath indexPathForRow:indexPath.row+1 inSection:0]];
                [arr addObject:[NSIndexPath indexPathForRow:indexPath.row+2 inSection:0]];
                [arr addObject:[NSIndexPath indexPathForRow:indexPath.row+3 inSection:0]];
            }
            
        } else {
            
            NSIndexPath *indexPath = [temp firstObject];
            if (indexPath.row>3) {
                [arr addObject:[NSIndexPath indexPathForRow:indexPath.row-3 inSection:0]];
                [arr addObject:[NSIndexPath indexPathForRow:indexPath.row-2 inSection:0]];
                [arr addObject:[NSIndexPath indexPathForRow:indexPath.row-1 inSection:0]];
            }
            
        }
        
        [self.needLoadArr addObjectsFromArray:arr];
        
    }

    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    NSLog(@" scrollViewWillBeginDragging。");

    [self.needLoadArr removeAllObjects];

}


//允许滑动到最顶端
- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView{
    NSLog(@" scrollViewShouldScrollToTop。");

    self.scrollToToping = YES;
    return YES;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    
    NSLog(@" scrollViewDidEndScrollingAnimation。");

    self.scrollToToping = NO;
    [self loadContent];
}


//已经滑动到最顶端
- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView{
    
    NSLog(@" scrollViewDidScrollToTop。");

    self.scrollToToping = NO;
    [self loadContent];
}


//用户触摸时第一时间加载内容
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    //NSLog(@" %s",__func__);
    NSLog(@" 用户触摸时第一时间加载内容");

    if (!self.scrollToToping) {
        [self.needLoadArr removeAllObjects];
        [self loadContent];
    }
    return [super hitTest:point withEvent:event];
}



- (void)loadContent{
    if (self.scrollToToping) {
        return;
    }
    if (self.indexPathsForVisibleRows.count<=0) {
        return;
    }
    
    if (self.visibleCells&&self.visibleCells.count>0) {
        for (id temp in [self.visibleCells copy]) {
            OptimizationTableViewCell *cell = (OptimizationTableViewCell *)temp;
            [cell draw];
        }
    }
    
}


#pragma mark 加载数据 对数据进行处理,特别是计算文本高度
- (void)loadData{
    
    //数组
    NSArray *temp = [NSArray  arrayWithContentsOfFile:[[NSBundle  mainBundle]  pathForResource:@"data" ofType:@"plist"]];
    
    for (NSDictionary *dict in temp) {
        NSDictionary *user = dict[@"user"];
        
        NSMutableDictionary *data = [NSMutableDictionary dictionary];
        data[@"avatarUrl"] = user[@"avatar_large"];
        data[@"name"] = user[@"screen_name"];
        data[@"time"] = user[@"screen_name"];
        data[@"text"] = dict[@"text"];

        NSString *from = [dict  valueForKey:@"source"];
        if (from.length > 6) { //过滤标签
            NSInteger start = [from  indexOf:@"\">"] + 2;
            NSInteger end = [from  indexOf:@"</a>"];
            from = [from  substringFromIndex:start toIndex:end];
        }else{
            from = @"未知";
        }
        data[@"from"] = from;
        
        [self  setCommentsFrom:dict toData:data];
        [self  setRepostsFrom:dict toData:data];
        
        
        NSDictionary *retweet = [dict valueForKey:@"retweeted_status"];
        if (retweet) {
            NSMutableDictionary *subData = [NSMutableDictionary dictionary];
            NSDictionary *user = retweet[@"user"];
            subData[@"avatarUrl"] = user[@"avatar_large"];
            subData[@"name"] = user[@"screen_name"];
            subData[@"text"] = [NSString stringWithFormat:@"@%@: %@", subData[@"name"], retweet[@"text"]];
            
            [self setPicUrlsFrom:retweet toData:subData];
            
            {
                //计算文本高度
                float width = [UIScreen screenWidth]-SIZE_GAP_LEFT*2;
                CGSize size = [subData[@"text"] sizeWithConstrainedToWidth:width fromFont:FontWithSize(SIZE_FONT_SUBCONTENT) lineSpace:5];
                NSInteger sizeHeight = (size.height+.5);
                subData[@"textRect"] = [NSValue valueWithCGRect:CGRectMake(SIZE_GAP_LEFT, SIZE_GAP_BIG, width, sizeHeight)];
                sizeHeight += SIZE_GAP_BIG;
                if (subData[@"pic_urls"] && [subData[@"pic_urls"] count]>0) {
                    sizeHeight += (SIZE_GAP_IMG+SIZE_IMAGE+SIZE_GAP_IMG);
                }
                sizeHeight += SIZE_GAP_BIG;
                subData[@"frame"] = [NSValue valueWithCGRect:CGRectMake(0, 0, [UIScreen screenWidth], sizeHeight)];
            }
            
            data[@"subData"] = subData;
        }else{
             [self setPicUrlsFrom:dict toData:data];
        }
        
        {
            float width = [UIScreen screenWidth]-SIZE_GAP_LEFT*2;
            CGSize size = [data[@"text"] sizeWithConstrainedToWidth:width fromFont:FontWithSize(SIZE_FONT_CONTENT) lineSpace:5];
            NSInteger sizeHeight = (size.height+.5);
            data[@"textRect"] = [NSValue valueWithCGRect:CGRectMake(SIZE_GAP_LEFT, SIZE_GAP_TOP+SIZE_AVATAR+SIZE_GAP_BIG, width, sizeHeight)];
            sizeHeight += SIZE_GAP_TOP+SIZE_AVATAR+SIZE_GAP_BIG;
            if (data[@"pic_urls"] && [data[@"pic_urls"] count]>0) {
                sizeHeight += (SIZE_GAP_IMG+SIZE_IMAGE+SIZE_GAP_IMG);
            }
            
            NSMutableDictionary *subData = [data valueForKey:@"subData"];
            if (subData) {
                sizeHeight += SIZE_GAP_BIG;
                CGRect frame = [subData[@"frame"] CGRectValue];
                CGRect textRect = [subData[@"textRect"] CGRectValue];
                frame.origin.y = sizeHeight;
                subData[@"frame"] = [NSValue valueWithCGRect:frame];
                textRect.origin.y = frame.origin.y+SIZE_GAP_BIG;
                subData[@"textRect"] = [NSValue valueWithCGRect:textRect];
                sizeHeight += frame.size.height;
                data[@"subData"] = subData;
            }
            
            sizeHeight += 30;
            data[@"frame"] = [NSValue valueWithCGRect:CGRectMake(0, 0, [UIScreen screenWidth], sizeHeight)];
        }

        [self.datas  addObject:data];
    }
    
    NSLog(@"数据源 ====== %@",self.datas);
    
}


//评论数量处理
#pragma mark 评论数量处理
- (void)setCommentsFrom:(NSDictionary *)dict toData:(NSMutableDictionary *)data{
    NSInteger comments = [dict[@"reposts_count"] integerValue];
    if (comments>=10000) {
        data[@"reposts"] = [NSString stringWithFormat:@"  %.1fw", comments/10000.0];
    } else {
        if (comments>0) {
            data[@"reposts"] = [NSString stringWithFormat:@"  %ld", (long)comments];
        } else {
            data[@"reposts"] = @"";
        }
    }
}

- (void)setRepostsFrom:(NSDictionary *)dict toData:(NSMutableDictionary *)data{
    NSInteger comments = [dict[@"comments_count"] integerValue];
    if (comments>=10000) {
        data[@"comments"] = [NSString stringWithFormat:@"  %.1fw", comments/10000.0];
    } else {
        if (comments>0) {
            data[@"comments"] = [NSString stringWithFormat:@"  %ld", (long)comments];
        } else {
            data[@"comments"] = @"";
        }
    }
}

#pragma mark 处理图片
- (void)setPicUrlsFrom:(NSDictionary *)dict toData:(NSMutableDictionary *)data{
    NSArray *pic_urls = [dict valueForKey:@"pic_urls"];
    NSString *url = [dict valueForKey:@"thumbnail_pic"];
    NSArray *pic_ids = [dict valueForKey:@"pic_ids"];
    if (pic_ids && pic_ids.count>1) {
        NSString *typeStr = @"jpg";
        if (pic_ids.count>0||url.length>0) {
            typeStr = [url substringFromIndex:url.length-3];
        }
        NSMutableArray *temp = [NSMutableArray array];
        for (NSString *pic_url in pic_ids) {
            [temp addObject:@{@"thumbnail_pic": [NSString stringWithFormat:@"http://ww2.sinaimg.cn/thumbnail/%@.%@", pic_url, typeStr]}];
        }
        data[@"pic_urls"] = temp;
    } else {
        data[@"pic_urls"] = pic_urls;
    }
}

#pragma mark 移除视图
- (void)removeFromSuperview{
    for (UIView *temp in self.subviews) {
        for (OptimizationTableViewCell *cell in temp.subviews) {
            if ([cell isKindOfClass:[OptimizationTableViewCell class]]) {
                [cell releaseMemory];
            }
        }
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.datas removeAllObjects];
    self.datas = nil;
    [self reloadData];
    self.delegate = nil;
    [self.needLoadArr removeAllObjects];
    self.needLoadArr = nil;
    [super removeFromSuperview];
}


@end















