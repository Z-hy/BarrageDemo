//
//  BulletView.m
//  BarrageDemo
//
//  Created by user on 2017/5/8.
//  Copyright © 2017年 user. All rights reserved.
//

#import "BulletView.h"

#define Padding 10

@interface BulletView ()

@property (nonatomic, strong) UILabel * lbComment; //

@end

@implementation BulletView

//初始化弹幕
- (instancetype)initWithComment:(NSString *)comment {
    if (self == [super init]) {
        self.backgroundColor = [UIColor redColor];
        //计算弹幕的实际宽度
        CGFloat width = [comment sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.0]}].width;
        self.bounds = CGRectMake(0, 0, width + Padding * 2, 30);
        self.lbComment.text = comment;
        self.lbComment.frame = CGRectMake(Padding, 0, width, 30);
    }
    return self;
}

- (void)calculatorFrameWithComment:(NSString *)comment {
    //计算弹幕的实际宽度
    CGFloat width = [comment sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.0]}].width;
    self.bounds = CGRectMake(0, 0, width + Padding * 2, 30);
    self.lbComment.text = comment;
    self.lbComment.frame = CGRectMake(Padding, 0, width, 30);
}

//开始动画
- (void)startAnimation {
    //根据弹幕的长度执行动画效果
    //根据v = s/t，时间相同情况下，距离越长，速度越快
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat duration = 6.0f;
    CGFloat wholeWidth = screenWidth + CGRectGetWidth(self.bounds);
    if (self.moveStatusBlock) {
        self.moveStatusBlock(Start);
    }
    // t = s/v;
    CGFloat speed = wholeWidth/duration;
    CGFloat enterDuration = CGRectGetWidth(self.bounds)/speed + 1;
    [self performSelector:@selector(enterScreen) withObject:nil afterDelay:enterDuration];
    __block CGRect frame = self.frame;
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        frame.origin.x -= wholeWidth;
        self.frame = frame;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        if (self.moveStatusBlock) {
            self.moveStatusBlock(End);
        }
    }];
}

- (void)enterScreen {
    if (self.moveStatusBlock) {
        self.moveStatusBlock(Enter);
    }
}

//结束动画
- (void)stopAnimation {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self.layer removeAllAnimations];
    [self removeFromSuperview];
}

- (UILabel *)lbComment {
    if (!_lbComment) {
        _lbComment = [[UILabel alloc] initWithFrame:CGRectZero];
        _lbComment.font = [UIFont systemFontOfSize:14.0];
        _lbComment.textColor = [UIColor whiteColor];
        _lbComment.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_lbComment];
    }
    return _lbComment;
}

@end
