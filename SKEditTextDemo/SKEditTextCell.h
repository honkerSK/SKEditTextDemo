//
//  SKEditTextCell.h
//  SKEditActivity
//
//  Created by KentSun on 2019/8/21.
//  Copyright © 2019 KentSun. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SKTextModel;

NS_ASSUME_NONNULL_BEGIN

@interface SKEditTextCell : UITableViewCell

@property (nonatomic, copy) void (^upTapBlock)(UIButton *sender);
@property (nonatomic, copy) void (^downTapBlock)(UIButton *sender);
@property (nonatomic, copy) void (^deleteTapBlock)(UIButton *sender, SKTextModel *textModel, NSInteger wordTotal);

//高度变化时 ,返回变化高度差 diffHeight
@property (nonatomic, copy) void (^changeCellHeightBlock)(CGFloat diffHeight);
/// 开始编辑
@property (nonatomic, copy) void(^textViewShouldBeginEditingBlock)(SKEditTextCell *cell);
/// 结束编辑 返回当前cell字数 ,总字数 和标识
@property (nonatomic, copy) void (^wordCountBlock)(NSInteger textNum, NSInteger wordTotal ,NSString *identifierModel);
/// 达到限制字符 下一步按钮 YES: 没有超, NO:超过限制字数
@property (nonatomic, copy) void (^maxTextLengthBlock)(BOOL isEnable);

/// 字数统计Label
@property (nonatomic ,weak) UILabel *wordCountLabel;

//模拟模型
@property (nonatomic, strong) SKTextModel *textModel;
// 是否为第一响应者
@property (nonatomic ,assign) BOOL isSkFirstResponder;

@end

NS_ASSUME_NONNULL_END
