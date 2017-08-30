//
//  OptimizationTableViewCell.m
//  OptimizationUITbaleView
//
//  Created by XueShan Zhang on 2017/8/29.
//  Copyright © 2017年 XueShan Zhang. All rights reserved.
//

#import "OptimizationTableViewCell.h"

#import "UIView+Additions.h"
#import "UIScreen+Additions.h"
#import "NSString+Additions.h"
#import "VVeboLabel.h"
#import "UIImageView+WebCache.h"
#import "UIButton+WebCache.h"


@implementation OptimizationTableViewCell{
    UIImageView *postBGView;
    UIButton *avatarViewBtn;
    UIImageView *cornerImage;
    UIView *topLine;
    
    VVeboLabel *labelVVeboLabel;
    VVeboLabel *detailVVeboLabel;
    
    UIScrollView *mulitPhotoScrollView;
    BOOL drawed; //是否已绘制,默认为NO
    NSInteger drawColorFlag;
    
    //评论坐标
    CGRect commentsRect;
    CGRect repostsRect;
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        self.clipsToBounds = YES;
        
        //1.背后的图片,单元格的高度等于postBGView的高度
        postBGView = [[UIImageView alloc] initWithFrame:CGRectZero];
        //postBGView.backgroundColor = [UIColor  redColor];
        [self.contentView insertSubview:postBGView atIndex:0];
        
        //2.个人图像按钮
        avatarViewBtn = [UIButton buttonWithType:UIButtonTypeCustom];//[[VVeboavatarViewBtn alloc] initWithFrame:avatarRect];
        avatarViewBtn.frame = CGRectMake(SIZE_GAP_LEFT, SIZE_GAP_TOP, SIZE_AVATAR, SIZE_AVATAR);//15,13,40,40
        //avatarViewBtn.backgroundColor = [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1];
        avatarViewBtn.backgroundColor = [UIColor  redColor];
        avatarViewBtn.hidden = NO;
        avatarViewBtn.tag = NSIntegerMax;
        avatarViewBtn.clipsToBounds = YES;
        [self.contentView addSubview:avatarViewBtn];
        
        //3.覆盖在个人图像按钮上的 圆形透明 图片   可不创建这个相框
        cornerImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SIZE_AVATAR+5, SIZE_AVATAR+5)];//0,0,45,45
        cornerImage.center = avatarViewBtn.center;
        cornerImage.image = [UIImage imageNamed:@"corner_circle@2x.png"];
        cornerImage.tag = NSIntegerMax;
        //cornerImage.backgroundColor = [UIColor  blueColor];
        [self.contentView addSubview:cornerImage];
        
        //4.最下面的红色的线
        topLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.height-.5, [UIScreen screenWidth], .5)];
        //topLine.backgroundColor = [UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1];
        topLine.backgroundColor = [UIColor  redColor];
        topLine.tag = NSIntegerMax;
        [self.contentView addSubview:topLine];
        
        self.backgroundColor = [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1];
        
        //5.
        [self addLabel];
        
        //6.盛图片的滚动视图
        mulitPhotoScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)]; //左边默认为0
        mulitPhotoScrollView.scrollsToTop = NO;
        mulitPhotoScrollView.showsHorizontalScrollIndicator = NO;
        mulitPhotoScrollView.showsVerticalScrollIndicator = NO;
        mulitPhotoScrollView.tag = NSIntegerMax;
        mulitPhotoScrollView.hidden = YES; //默认隐藏
        [self.contentView addSubview:mulitPhotoScrollView];
        
    
        int h2 = SIZE_GAP_IMG+SIZE_IMAGE;//5,80
        
        //循环创建 9张图片,放在 mulitPhotoScrollView 滚动视图上
        for (NSInteger i=0; i<9; i++) {
            int g = SIZE_GAP_IMG;//5
            int width = SIZE_IMAGE;//80
            float x = SIZE_GAP_LEFT+(g+width)*(i%3);//15
            float y = i/3*h2;
            UIImageView *thumb1 = [[UIImageView alloc] initWithFrame:CGRectMake(x, y+2, SIZE_IMAGE, SIZE_IMAGE)];//80,80
            thumb1.tag = i+1;
            [mulitPhotoScrollView addSubview:thumb1];
        }

    }return self;
    
}

- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    [self.contentView bringSubviewToFront:topLine];
    topLine.y = self.height-.5;
}


//中间动态改变的文字Label
- (void)addLabel{
    
    //图像下面的 标签
    if (labelVVeboLabel) {
        [labelVVeboLabel removeFromSuperview];
        labelVVeboLabel = nil;
    }
    
    //详情标签detailVVeboLabel
    if (detailVVeboLabel) {
        detailVVeboLabel = nil;
    }
    
    //1.图像下面的 标签
    labelVVeboLabel = [[VVeboLabel alloc] initWithFrame:[_data[@"textRect"] CGRectValue]];
    labelVVeboLabel.textColor = [UIColor colorWithRed:50/255.0 green:50/255.0 blue:50/255.0 alpha:1];
    labelVVeboLabel.backgroundColor = [UIColor  blueColor];//self.backgroundColor;
    [self.contentView addSubview:labelVVeboLabel];
    
    //2.详情标签
    detailVVeboLabel = [[VVeboLabel alloc] initWithFrame:[_data[@"subTextRect"] CGRectValue]];
    detailVVeboLabel.font = FontWithSize(SIZE_FONT_SUBCONTENT);
    detailVVeboLabel.textColor = [UIColor colorWithRed:50/255.0 green:50/255.0 blue:50/255.0 alpha:1];;
    detailVVeboLabel.backgroundColor = [UIColor  orangeColor];//[UIColor colorWithRed:243/255.0 green:243/255.0 blue:243/255.0 alpha:1];
    [self.contentView  addSubview:detailVVeboLabel];
}



//1.赋值 --- 这里只赋值 左上角 图像按钮
- (void)setData:(NSDictionary *)data{
    
    _data = data;
    
    [avatarViewBtn setBackgroundImage:nil forState:UIControlStateNormal];
    
    //左上角按钮附图片
    if ([data valueForKey:@"avatarUrl"]) {
        NSURL *url = [NSURL URLWithString:[data valueForKey:@"avatarUrl"]];
        [avatarViewBtn sd_setBackgroundImageWithURL:url forState:UIControlStateNormal placeholderImage:nil options:SDWebImageLowPriority];
    }
    
}


//2.将主要内容绘制到图片上,异步处理
- (void)draw{
    
    if (drawed) {
        //如果已绘制,return
        return;
    }
    
    NSInteger flag = drawColorFlag;
    
    drawed = YES;//标记为已绘制
    
    //异步绘制
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //1.从数据源中取出坐标
        CGRect rect = [_data[@"frame"] CGRectValue];
        //2.开始绘制
        UIGraphicsBeginImageContextWithOptions(rect.size, YES, 0);
        //3.绘制
        CGContextRef context = UIGraphicsGetCurrentContext();
        [[UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1] set];
        CGContextFillRect(context, rect);
        
        if ([_data valueForKey:@"subData"]) {
            [[UIColor colorWithRed:243/255.0 green:243/255.0 blue:243/255.0 alpha:1] set];
            CGRect subFrame = [_data[@"subData"][@"frame"] CGRectValue];
            CGContextFillRect(context, subFrame);
            [[UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1] set];
            CGContextFillRect(context, CGRectMake(0, subFrame.origin.y, rect.size.width, .5));
        }
        
        {
            float leftX = SIZE_GAP_LEFT+SIZE_AVATAR+SIZE_GAP_BIG;
            float x = leftX;
            float y = (SIZE_AVATAR-(SIZE_FONT_NAME+SIZE_FONT_SUBTITLE+6))/2-2+SIZE_GAP_TOP+SIZE_GAP_SMALL-5;
            [_data[@"name"] drawInContext:context withPosition:CGPointMake(x, y) andFont:FontWithSize(SIZE_FONT_NAME)
                             andTextColor:[UIColor colorWithRed:106/255.0 green:140/255.0 blue:181/255.0 alpha:1]
                                andHeight:rect.size.height];
            y += SIZE_FONT_NAME+5;
            float fromX = leftX;
            float size = [UIScreen screenWidth]-leftX;
            NSString *from = [NSString stringWithFormat:@"%@  %@", _data[@"time"], _data[@"from"]];
            [from drawInContext:context withPosition:CGPointMake(fromX, y) andFont:FontWithSize(SIZE_FONT_SUBTITLE)
                   andTextColor:[UIColor colorWithRed:178/255.0 green:178/255.0 blue:178/255.0 alpha:1]
                      andHeight:rect.size.height andWidth:size];
        }
        
        {
            CGRect countRect = CGRectMake(0, rect.size.height-30, [UIScreen screenWidth], 30);
            [[UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1] set];
            CGContextFillRect(context, countRect);
            float alpha = 1;
            
            float x = [UIScreen screenWidth]-SIZE_GAP_LEFT-10;
            NSString *comments = _data[@"comments"];
            if (comments) {
                CGSize size = [comments sizeWithConstrainedToSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) fromFont:FontWithSize(SIZE_FONT_SUBTITLE) lineSpace:5];
                
                x -= size.width;
                [comments drawInContext:context withPosition:CGPointMake(x, 8+countRect.origin.y)
                                andFont:FontWithSize(12)
                           andTextColor:[UIColor colorWithRed:178/255.0 green:178/255.0 blue:178/255.0 alpha:1]
                              andHeight:rect.size.height];
                [[UIImage imageNamed:@"t_comments.png"] drawInRect:CGRectMake(x-5, 10.5+countRect.origin.y, 10, 9) blendMode:kCGBlendModeNormal alpha:alpha];
                commentsRect = CGRectMake(x-5, self.height-50, [UIScreen screenWidth]-x+5, 50);
                x -= 20;
            }
            
            NSString *reposts = _data[@"reposts"];
            if (reposts) {
                CGSize size = [reposts sizeWithConstrainedToSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) fromFont:FontWithSize(SIZE_FONT_SUBTITLE) lineSpace:5];
                
                x -= MAX(size.width, 5)+SIZE_GAP_BIG;
                [reposts drawInContext:context withPosition:CGPointMake(x, 8+countRect.origin.y)
                               andFont:FontWithSize(12)
                          andTextColor:[UIColor colorWithRed:178/255.0 green:178/255.0 blue:178/255.0 alpha:1]
                             andHeight:rect.size.height];
                
                [[UIImage imageNamed:@"t_repost.png"] drawInRect:CGRectMake(x-5, 11+countRect.origin.y, 10, 9) blendMode:kCGBlendModeNormal alpha:alpha];
                repostsRect = CGRectMake(x-5, self.height-50, commentsRect.origin.x-x, 50);
                x -= 20;
            }
            
            [@"•••" drawInContext:context
                     withPosition:CGPointMake(SIZE_GAP_LEFT, 8+countRect.origin.y)
                          andFont:FontWithSize(11)
                     andTextColor:[UIColor colorWithRed:178/255.0 green:178/255.0 blue:178/255.0 alpha:.5]
                        andHeight:rect.size.height];
            
            if ([_data valueForKey:@"subData"]) {
                [[UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1] set];
                CGContextFillRect(context, CGRectMake(0, rect.size.height-30.5, rect.size.width, .5));
            }
        }
        
        //4.获取绘制好的图片
        UIImage *temp = UIGraphicsGetImageFromCurrentImageContext();
        //5.结束绘制
        UIGraphicsEndImageContext();
        //6.主线程刷新数据
        dispatch_async(dispatch_get_main_queue(), ^{
            if (flag==drawColorFlag) {
                postBGView.frame = rect; //更改坐标,postBGView的坐标高度,就是单元格的高度
                postBGView.backgroundColor = [UIColor  redColor];
                postBGView.image = nil;
                postBGView.image = temp;
            }
        });
        
    });
    
    [self drawText];
    
    //2.加载滚动视图 上的图片
    [self loadThumb];
}

//3.将文本内容绘制到图片上
- (void)drawText{
    
    if (labelVVeboLabel==nil || detailVVeboLabel==nil) {
        
        [self addLabel];
    }
    
    labelVVeboLabel.frame = [_data[@"textRect"] CGRectValue];
    
    [labelVVeboLabel setText:_data[@"text"]];
    
    if ([_data valueForKey:@"subData"]) {
        detailVVeboLabel.frame = [[_data valueForKey:@"subData"][@"textRect"] CGRectValue];
        [detailVVeboLabel setText:[_data valueForKey:@"subData"][@"text"]];
        detailVVeboLabel.hidden = NO;
    }
    
}


//4.滚动视图上的图片处理
- (void)loadThumb{
    float y = 0;
    NSArray *urls;
    if ([_data valueForKey:@"subData"]) {
        CGRect subPostRect = [_data[@"subData"][@"textRect"] CGRectValue];
        y = subPostRect.origin.y+subPostRect.size.height+SIZE_GAP_BIG;
        urls = [_data valueForKey:@"subData"][@"pic_urls"];
    } else {
        CGRect postRect = [_data[@"textRect"] CGRectValue];
        y = postRect.origin.y+postRect.size.height+SIZE_GAP_BIG;
        urls = _data[@"pic_urls"];
    }
    
    if (urls.count>0) {
        mulitPhotoScrollView.hidden = NO;//不隐藏
        mulitPhotoScrollView.y = y;
        
        //更改坐标
        mulitPhotoScrollView.frame = CGRectMake(0, y, [UIScreen screenWidth], SIZE_GAP_IMG+((SIZE_GAP_IMG+SIZE_IMAGE)*(urls.count)));
        
        for (NSInteger i=0; i<9; i++) {
            //获取上面创建好的 9个图像
            UIImageView *thumbView = (UIImageView *)[mulitPhotoScrollView viewWithTag:i+1];
            thumbView.contentMode = UIViewContentModeScaleAspectFill;
            thumbView.backgroundColor = [UIColor lightGrayColor];
            thumbView.clipsToBounds = YES;
            
            if (i<urls.count) {
                thumbView.frame = CGRectMake(SIZE_GAP_LEFT+(SIZE_GAP_IMG+SIZE_IMAGE)*i, .5, SIZE_IMAGE, SIZE_IMAGE);
                thumbView.hidden = NO;
                NSDictionary *url = urls[i];
                [thumbView sd_setImageWithURL:[NSURL URLWithString:url[@"thumbnail_pic"]]];
            } else {
                thumbView.hidden = YES;
            }
        }
        float cw = SIZE_GAP_LEFT*2+(SIZE_GAP_IMG+SIZE_IMAGE)*urls.count;
        if (cw<self.width) {
            cw = self.width;
        }
        if (mulitPhotoScrollView.contentSize.width!=cw) {
            mulitPhotoScrollView.contentSize = CGSizeMake(cw, 0);
        }
    }
}

- (void)clear{
    if (!drawed) {
        return;
    }
    postBGView.frame = CGRectZero;
    postBGView.image = nil;
    [labelVVeboLabel clear];
    
    if (!detailVVeboLabel.hidden) {
        detailVVeboLabel.hidden = YES;
        [detailVVeboLabel clear];
    }
    for (UIImageView *thumb1 in mulitPhotoScrollView.subviews) {
        if (!thumb1.hidden) {
            [thumb1 sd_cancelCurrentAnimationImagesLoad];
        }
    }
    if (mulitPhotoScrollView.contentOffset.x!=0) {
        [mulitPhotoScrollView setContentOffset:CGPointZero animated:NO];
    }
    mulitPhotoScrollView.hidden = YES;
    drawColorFlag = arc4random();
    drawed = NO;
}

- (void)releaseMemory{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //	if ([self.delegate keepCell:self]) {
    //		return;
    //	}
    [self clear];
    [super removeFromSuperview];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"postview dealloc %@", self);
}


@end











