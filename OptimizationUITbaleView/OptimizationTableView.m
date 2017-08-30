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
        NSLog(@" initWithFrame  bool %d",self.scrollToToping);
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
    
   // cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [cell clear];
    
    cell.data = data; //赋值
    
    if (self.needLoadArr.count>0&&[self.needLoadArr indexOfObject:indexPath]==NSNotFound) {
        
        [cell clear];
        return;
    }
    
    if (self.scrollToToping) {
        
        //NSLog(@" drawCell:(OptimizationTableViewCell *)cell  bool %d",self.scrollToToping);

        return;
    }
    
    [cell draw]; //绘制视图,异步加载
}


//行高 先走heightForRowAtIndexPath,再走cellForRow
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //从数据源中取出 已经计算好的坐标
    NSDictionary *dict = self.datas[indexPath.row];
    float height = [dict[@"frame"] CGRectValue].size.height;
    
    //NSLog(@"行高 %ld",(long)height);
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
        NSLog(@"按需加载  %lu",(unsigned long)self.needLoadArr.count);

    }

    
}

//刚开始拖拽
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    //NSLog(@" scrollViewWillBeginDragging。");

    [self.needLoadArr removeAllObjects];
    //NSLog(@" self.needLoadArr.count  == %lu",(unsigned long)self.needLoadArr.count);
}


//允许滑动到最顶端
- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView{
    //NSLog(@" scrollViewShouldScrollToTop。");

    self.scrollToToping = YES;
    
    return YES;
}


//已经滑到最顶端
- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView{
    
    //NSLog(@" scrollViewDidScrollToTop。");

    self.scrollToToping = NO;
    [self loadContent];
}

//结束动画
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    
    //NSLog(@" scrollViewDidEndScrollingAnimation。");
    
    self.scrollToToping = NO;
    [self loadContent];
}


//用户触摸时第一时间加载内容
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    //NSLog(@" %s",__func__);
    //NSLog(@" 用户触摸时第一时间加载内容");

    //NSLog(@" hitTest  bool %d",self.scrollToToping);

    if (!self.scrollToToping) {
        //NSLog(@" hitTest !self.scrollToToping  bool %d",!self.scrollToToping);

        [self.needLoadArr removeAllObjects];
        [self loadContent];
    }
    return [super hitTest:point withEvent:event];
}



- (void)loadContent{
    
    if (self.scrollToToping) {
        //NSLog(@" loadContent  bool %d",self.scrollToToping);
        return;
    }
    
    if (self.indexPathsForVisibleRows.count<=0) {
        return;
    }
    
    if (self.visibleCells&&self.visibleCells.count>0) {
       // NSLog(@" loadContent %lu",(unsigned long)self.visibleCells.count);

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
                //计算文本高度  --- 下面的[data valueForKey:@"subData"]用
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
            //复杂业务逻辑处理,计算高度,将上面处理的[data valueForKey:@"subData"] 再处理
            float width = [UIScreen screenWidth]-SIZE_GAP_LEFT*2;
            CGSize size = [data[@"text"] sizeWithConstrainedToWidth:width fromFont:FontWithSize(SIZE_FONT_CONTENT) lineSpace:5];
            NSInteger sizeHeight = (size.height+.5);
            data[@"textRect"] = [NSValue valueWithCGRect:CGRectMake(SIZE_GAP_LEFT, SIZE_GAP_TOP+SIZE_AVATAR+SIZE_GAP_BIG, width, sizeHeight)];
            //15,63,[UIScreen screenWidth]-15*2,sizeHeight
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
            //最后保存到数据字典里的frame
            data[@"frame"] = [NSValue valueWithCGRect:CGRectMake(0, 0, [UIScreen screenWidth], sizeHeight)];
        }

        [self.datas  addObject:data];
    }
    
    NSLog(@"数据源 ====== %@",[self.datas  objectAtIndex:0]);
    
}

/*
 
 数据源 ====== {
 avatarUrl = "http://tp2.sinaimg.cn/2737550397/180/5722396393/0";
 comments = "";
 frame = "NSRect: {{0, 0}, {375, 351}}";
 from = "\U4e09\U661fGALAXY S4";
 name = "\U6280\U80fd\U9171";
 reposts = "  8";
 subData =     {
 avatarUrl = "http://tp3.sinaimg.cn/1662495630/180/40070174303/0";
 frame = "NSRect: {{0, 90}, {375, 231}}";
 name = "\U51cf\U80a5\U5973\U5b69";
 "pic_urls" =         (
 {
 "thumbnail_pic" = "http://ww4.sinaimg.cn/thumbnail/e9b0182bgw1eodotr8qdsg208204haev.gif";
 },
 {
 "thumbnail_pic" = "http://ww1.sinaimg.cn/thumbnail/e9b0182bgw1eodotru9afg208204gn5k.gif";
 },
 {
 "thumbnail_pic" = "http://ww3.sinaimg.cn/thumbnail/e9b0182bgw1eodots5h32g208204gjvj.gif";
 },
 {
 "thumbnail_pic" = "http://ww3.sinaimg.cn/thumbnail/e9b0182bgw1eodotspcwag208204gwog.gif";
 },
 {
 "thumbnail_pic" = "http://ww1.sinaimg.cn/thumbnail/e9b0182bgw1eodott3nbcg208204fafn.gif";
 },
 {
 "thumbnail_pic" = "http://ww3.sinaimg.cn/thumbnail/e9b0182bgw1eodottg80sg208204gaf2.gif";
 }
 );
 text = "@\U51cf\U80a5\U5973\U5b69: \U3010\U5e73\U5766\U5c0f\U8179\U6559\U7a0b\U3011\U5c0f\U8179\U7ec3\U4e60\U52a8\U4f5c\Uff0c\U60f3\U7529\U8089\U5c31\U5f97\U52aa\U529b\Uff01\Uff01fighting\Uff01\Uff01\Uff01\U516d\U7ec4\U52a8\U4f5c\Uff0c\U6bcf\U4e2a\U52a8\U4f5c20\U4e2a\Uff0c\U521a\U5f00\U59cb\U505a\U89c9\U5f97\U96be\U5ea6\U5927\Uff0c\U53ef\U4ee5\U4ece10\U4e2a\U5f00\U59cb\U505a\Uff0c\U6839\U636e\U4f60\U4e2a\U4eba\U4f53\U8d28\Uff0c\U6bcf\U5929\U53ef\U4ee5\U9010\U6e10\U589e\U52a0\U6570\U91cf\U3002\U53ea\U8981\U575a\U6301\Uff0c\U6548\U679c\U7edd\U5bf9good\U3002\U6211\U4eec\U8981\U5b9e\U9645\U884c\U52a8\U6765\U8bc1\U660e\Uff0c\U8fdc\U79bb\U81ea\U5df1\U7684\U5669\U68a6\Uff01";
 textRect = "NSRect: {{15, 100}, {345, 121}}";
 };
 text = "\U3010\U5e73\U5766\U5c0f\U8179\U6559\U7a0b\U3011[\U8bdd\U7b52]";
 textRect = "NSRect: {{15, 63}, {345, 17}}";
 time = "\U6280\U80fd\U9171";
 }

 
 */

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















