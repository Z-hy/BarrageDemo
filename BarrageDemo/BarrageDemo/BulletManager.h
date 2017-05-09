//
//  BulletManager.h
//  BarrageDemo
//
//  Created by user on 2017/5/8.
//  Copyright © 2017年 user. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BulletView;

@interface BulletManager : NSObject

@property (nonatomic, copy) void (^generateViewBlock)(BulletView *view);

//弹幕开始执行
- (void)start;

//弹幕结束执行
- (void)stop;

@end
