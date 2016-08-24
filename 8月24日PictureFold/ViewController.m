//
//  ViewController.m
//  8月24日PictureFold
//
//  Created by 李景浩 on 16/8/24.
//  Copyright © 2016年 李大米. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *topView;
@property (weak, nonatomic) IBOutlet UIImageView *bottomView;
@property (weak, nonatomic) IBOutlet UIView *panView;
@property (weak,nonatomic) CAGradientLayer *grandient;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    设置锚点，使之正好无缝拼接
    self.topView.layer.anchorPoint = CGPointMake(0.5, 1);
    self.bottomView.layer.anchorPoint = CGPointMake(0.5,0);
    
//    只显示上部分或者下部分
    self.topView.layer.contentsRect = CGRectMake(0, 0, 1, 0.5);
    self.bottomView.layer.contentsRect = CGRectMake(0, 0.5, 1, 0.5);
    
//    手势下拉
    UIPanGestureRecognizer *panGeR = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panSection:)];
    [self.panView addGestureRecognizer:panGeR];
    
//    添加渐变层
    CAGradientLayer *grandient = [CAGradientLayer layer];
    grandient.frame = self.bottomView.bounds;
    grandient.colors = @[(id)[UIColor clearColor].CGColor,(id)[UIColor blackColor].CGColor];
    
//    设置不透明度
    grandient.opacity = 0;
    self.grandient = grandient;
    
    [self.bottomView.layer addSublayer:grandient];
    
    
    
}

-(void)panSection:(UIPanGestureRecognizer *)pan{

//    获取手势的区域
    CGPoint dragP = [pan translationInView:self.panView];
//    根据手势上下移动的范围确定旋转的角度
    CGFloat angle = dragP.y / self.panView.bounds.size.height * M_PI;
//    使之移动有近大远小的效果
    CATransform3D transform = CATransform3DIdentity;
//    立体效果
    transform.m34 = -1/200.0;
//    为什么不用Make,make会让m34清空,这个地方不能让m34清空
    self.topView.layer.transform = CATransform3DRotate(transform, -angle, 1, 0, 0);
    
//    设置不透明度
    self.grandient.opacity = dragP.y / self.panView.bounds.size.height;
    
    
//    手势结束后
    if (pan.state == UIGestureRecognizerStateEnded) {
        self.grandient.opacity = 0;
    //Duration:动画执行的时长
    //Damping:弹性系数, 值设的越小,弹的就越很.
        [UIView animateWithDuration:1 delay:0 usingSpringWithDamping:0.25 initialSpringVelocity:0 options:UIViewAnimationOptionCurveLinear animations:^{
//            使上部分回弹
            self.topView.layer.transform = CATransform3DIdentity;
            
        } completion:^(BOOL finished) {
            
        }];
    }
}


@end
