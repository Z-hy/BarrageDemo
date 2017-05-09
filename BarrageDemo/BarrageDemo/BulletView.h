//
//  BulletView.h
//  BarrageDemo
//
//  Created by user on 2017/5/8.
//  Copyright © 2017年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MoveStatus) {
    Start,
    Enter,
    End
};

@interface BulletView : UIView

@property (nonatomic, assign) NSInteger trajectory; //弹道
@property (nonatomic, copy) void (^moveStatusBlock)(MoveStatus status);//弹幕状态回调

//初始化弹幕
- (instancetype)initWithComment:(NSString *)comment;
//获取到可复用的view后，根据comment长度重新计算宽度。
- (void)calculatorFrameWithComment:(NSString *)comment;

//开始动画
- (void)startAnimation;

//结束动画
- (void)stopAnimation;

@end
