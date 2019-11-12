//
//  SKTextModel.h
//  xiangwan
//
//  Created by KentSun on 2019/8/27.
//  Copyright © 2019 KentSun. All rights reserved.
//

// SKEditTextCell 对应模型
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SKTextModel : NSObject

// 模型标识
@property (nonatomic, copy) NSString *identifierModel;
/// 编辑文字内容
@property (nonatomic, copy) NSString *content;
/// 记录当前cell字数
@property (nonatomic, assign) NSInteger textNum;
/// 已经写的总字数
@property (nonatomic, assign) NSInteger wordTotal;

// 记录按钮是否可点击
@property (nonatomic, assign) BOOL upBtnEnable;
@property (nonatomic, assign) BOOL downBtnEnable;
@property (nonatomic, assign) BOOL deleteEnable;

//返回计算textView高度
@property (nonatomic, assign) CGFloat textViewHeight;
//返回计算lable高度
//@property (nonatomic, assign) CGFloat contentLabelHeight;


@end

NS_ASSUME_NONNULL_END
