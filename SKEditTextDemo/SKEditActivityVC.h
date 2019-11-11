//
//  SKEditActivityVC.h
//  xiangwan
//
//  Created by mac on 2019/8/21.
//  Copyright © 2019 mac. All rights reserved.
//
// 编辑活动控制器 
#import <UIKit/UIKit.h>
@class SKActivity;

NS_ASSUME_NONNULL_BEGIN

@interface SKEditActivityVC : UIViewController

@property (nonatomic, strong) SKActivity *activity; //活动模型 保存提交数据

@end

NS_ASSUME_NONNULL_END
