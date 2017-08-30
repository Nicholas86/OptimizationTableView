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
    UIImageView *imageView;
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
    
    /*
    imageView = [[UIImageView  alloc] initWithFrame:CGRectMake(10, 150, 300, 200)];
    imageView.backgroundColor = [UIColor  lightGrayColor];
    [self.view  addSubview:imageView];
    */
    
   // [self  drawImageView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)drawImageView{
    
    imageView.image = [self   createShareImage:[UIImage  imageNamed:@"引导页1"] Context:@"你是谁爱空间管控安静啊司空见惯感觉快拉三个看见了乐扣乐扣就爱看垃圾管理开始考虑居民"];
}


// 1.将文字添加到图片上;imageName 图片名字， text 需画的字体
- (UIImage *)createShareImage:(UIImage *)tImage Context:(NSString *)text
{

    UIGraphicsBeginImageContextWithOptions(tImage.size, NO, 0.0);
    
    [tImage drawAtPoint:CGPointMake(0, 0)];
    NSLog(@"图片: %f %f",tImage.size.width,tImage.size.height);

    //获得 图形上下文
    CGContextRef context=UIGraphicsGetCurrentContext();
    CGContextDrawPath(context, kCGPathStroke);
    CGFloat nameFont = 40.f;
    //画 自己想要画的内容
    NSDictionary *attributes = @{
                                 NSFontAttributeName:[UIFont systemFontOfSize:nameFont],
                                 //NSForegroundColorAttributeName:[UIColor  redColor]
                                 };
    
    CGRect sizeToFit = [text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, nameFont) options:NSStringDrawingUsesDeviceMetrics attributes:attributes context:nil];
    
    
    NSLog(@"sizeToFit: %f %f",sizeToFit.size.width,sizeToFit.size.height);
    
    CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
    
    //(tImage.size.width - sizeToFit.size.width)/2
    [text drawAtPoint:CGPointMake(50,60) withAttributes:@{
                    NSFontAttributeName:[UIFont systemFontOfSize:nameFont],
                    NSForegroundColorAttributeName:[UIColor  redColor]
                    }];
    //返回绘制的新图形
    
    UIImage *newImage=UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}




// 2. 在图片上添加图片;imageName 1.底部图片名字imageName， image2 需添加的图片
- (UIImage *)createShareImage:(UIImage *)tImage ContextImage:(UIImage *)image2
{
    UIImage *sourceImage = tImage;
    CGSize imageSize; //画的背景 大小
    imageSize = [sourceImage size];
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.0);
    [sourceImage drawAtPoint:CGPointMake(0, 0)];
    //获得 图形上下文
    CGContextRef context=UIGraphicsGetCurrentContext();
    //画 自己想要画的内容(添加的图片)
    CGContextDrawPath(context, kCGPathStroke);
    
    CGRect rect = CGRectMake( imageSize.width/4,imageSize.height/5, imageSize.width/2, imageSize.height/2);
    CGContextAddEllipseInRect(context, rect);
    CGContextClip(context);
    
    [image2 drawInRect:rect];
    
    //返回绘制的新图形
    
    UIImage *newImage=UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return newImage;
}


@end





