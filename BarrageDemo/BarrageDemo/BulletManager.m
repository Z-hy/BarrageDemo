//
//  BulletManager.m
//  BarrageDemo
//
//  Created by user on 2017/5/8.
//  Copyright © 2017年 user. All rights reserved.
//

#import "BulletManager.h"
#import "BulletView.h"

@interface BulletManager ()

//弹幕的数据源
@property (nonatomic, strong) NSMutableArray *dataSource;
//弹幕使用过程中的数组变量
@property (nonatomic, strong) NSMutableArray *bulletComments;
//存储弹幕view的数组变量
@property (nonatomic, strong) NSMutableArray *bulletViews;
//存储滚出屏幕的view的数组变量
@property (nonatomic, strong) NSMutableArray *recycleViews;
@property (nonatomic, assign) NSInteger count;

@property BOOL bStopAnimation;

@end

@implementation BulletManager

- (instancetype)init {
    if (self == [super init]) {
        self.bStopAnimation = YES;
        self.count = 0;
    }
    return self;
}

- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray arrayWithArray:@[@"弹幕1~~~~~~", @"弹幕2~~~~~~~~~~~~", @"弹幕3~~~~~~~~~~~~~~~~~~~", @"弹幕4~~~~~~~", @"弹幕5~~~~~~~", @"弹幕6~~~~~~~", @"弹幕7~~~~~~~", @"弹幕8~~~~~~~", @"弹幕9~~~~~~~", @"弹幕10~~~~~~~", @"弹幕11~~~~~~~", @"弹幕12~~~~~~~", @"弹幕13~~~~~~~", @"弹幕14~~~~~~~", ]];
    }
    return _dataSource;
}

- (NSMutableArray *)bulletComments {
    if (!_bulletComments) {
        _bulletComments = [NSMutableArray array];
    }
    return _bulletComments;
}

- (NSMutableArray *)bulletViews {
    if (!_bulletViews) {
        _bulletViews = [NSMutableArray array];
    }
    return _bulletViews;
}

- (NSMutableArray *)recycleViews {
    if (!_recycleViews) {
        _recycleViews = [NSMutableArray array];
    }
    return _recycleViews;
}

//初始化弹幕，随机分配弹幕轨迹
- (void)initBulletComment {
    NSMutableArray *trajectorys = [NSMutableArray arrayWithArray:@[@(0), @(1), @(2)]];
    for (int i = 0; i < 3; i++) {
        if (self.bulletComments.count > 0) {
            //通过随机数获取到弹幕的轨迹
            NSInteger index = arc4random()%trajectorys.count;
            int tr = [[trajectorys objectAtIndex:index] intValue];
            [trajectorys removeObjectAtIndex:index];
            //从弹幕数组中逐一取出弹幕数据
            NSString *comment = [self.bulletComments firstObject];
            [self.bulletComments removeObjectAtIndex:0];
            //创建弹幕view
            //复用view
            if (self.recycleViews.count > 0) {
                BulletView *view = [self getRecycleBulletView];
                NSLog(@"开始复用了1");
                [view calculatorFrameWithComment:comment];
                view.trajectory = tr;
                [self run:view trajectory:tr];
            } else {
                [self createBulletView:comment trajectory:tr];
            }
            //不复用view
//            [self createBulletView:comment trajectory:tr];

        }
    }
}

- (void)run:(BulletView *)view trajectory:(int)trajectory {
    __weak typeof (view) weakView = view;
    __weak typeof (self) weakSelf = self;
    view.moveStatusBlock = ^(MoveStatus status){
        if (self.bStopAnimation) {
            return;
        }
        switch (status) {
            case Start:
                //弹幕开始进入屏幕，将view加入弹幕管理的变量bulletViews中
                if (![weakSelf.bulletViews containsObject:weakView]) {
                    [weakSelf.bulletViews addObject:weakView];
                }
                break;
            case Enter: {
                //弹幕完全进入屏幕，判断是否还有其他内容，如果有则在该弹幕轨迹中创建一个弹幕
                NSString *comment = [weakSelf nextComment];
                if (comment) {
                    //复用view
                    if (weakSelf.recycleViews.count > 0) {
                        BulletView *view = [weakSelf getRecycleBulletView];
                        NSLog(@"开始复用了2");
                        [view calculatorFrameWithComment:comment];
                        view.trajectory = trajectory;
                        [weakSelf run:view trajectory:trajectory];
                    } else {
                        [weakSelf createBulletView:comment trajectory:trajectory];
                    }
                    //不复用view
//                    [weakSelf createBulletView:comment trajectory:trajectory];
                }
                break;
            }
            case End:{
                //弹幕完全飞出屏幕后从bulletViews中删除，释放资源
                if ([weakSelf.bulletViews containsObject:weakView]) {
                    [weakSelf.recycleViews addObject:weakView];
                    //将滚动出屏幕的view回收
                    [weakSelf.bulletViews removeObject:weakView];
                    [weakView stopAnimation];
                }
                if (weakSelf.bulletViews.count == 0) {
                    //说明屏幕上已经没有弹幕了，开始循环滚动
                    weakSelf.bStopAnimation = YES;
                    [weakSelf start];
                }
                break;
            }
            default:
                break;
        }
    };
    if (self.generateViewBlock) {
        self.generateViewBlock(view);
    }
}

- (void)createBulletView:(NSString *)comment trajectory:(int)trajectory {
    if (self.bStopAnimation) {
        return;
    }
    BulletView *view = [[BulletView alloc] initWithComment:comment];
    self.count++;
    NSLog(@"create bulletView: %ld", (long)self.count);
    view.trajectory = trajectory;
    [self run:view trajectory:trajectory];
}

- (NSString *)nextComment {
    NSString *comment = nil;
    if (self.bulletComments.count > 0) {
       comment = [self.bulletComments firstObject];
        if (comment) {
            [self.bulletComments removeObjectAtIndex:0];
        }
    }
   return comment;
}

//获取到可复用的BulletView
- (BulletView *)getRecycleBulletView {
    if (self.recycleViews.count <= 0) {
        return nil;
    }
    BulletView *view = [self.recycleViews objectAtIndex:0];
    [self.recycleViews removeObjectAtIndex:0];
    [self.bulletViews addObject:view];
    return view;
}

//弹幕开始执行
- (void)start {
    if (!self.bStopAnimation) {
        return;
    }
    self.bStopAnimation = NO;
    [self.bulletComments removeAllObjects];
    [self.bulletComments addObjectsFromArray:self.dataSource];
    [self initBulletComment];
}

//弹幕结束执行
- (void)stop {
    if (self.bStopAnimation) {
        return;
    }
    self.bStopAnimation = YES;
    [self.bulletViews enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BulletView *view = obj;
        [view stopAnimation];
        view = nil;
    }];
    [self.bulletViews removeAllObjects];
    [self.recycleViews enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BulletView *view = obj;
        [view stopAnimation];
        view = nil;
    }];
    [self.recycleViews removeAllObjects];
}

@end
