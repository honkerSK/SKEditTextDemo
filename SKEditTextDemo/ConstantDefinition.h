//
//  ConstantDefinition.h
//  CQ_App
//
//  Created by mac on 2019/3/21.
//  Copyright © 2019年 mac. All rights reserved.
//

#ifndef ConstantDefinition_h
#define ConstantDefinition_h


#pragma mark - ——————— 字体与颜色相关 ————————
CG_INLINE UIFont *FONTSIZE(CGFloat a) {
    return [UIFont fontWithName:@"PingFangSC-Regular" size:a];
}
CG_INLINE UIFont *FONTBOLDSIZE(CGFloat a) {
    return [UIFont fontWithName:@"PingFangSC-Semibold" size:a];
}


//品牌色
CG_INLINE UIColor * BRANDCOLOR() {
    return RGBACOLOR(0, 212, 231, 1.0);
}
//辅助色
CG_INLINE UIColor * AUXILIARYCOLOR() {
    return RGBACOLOR(199, 164, 104, 1.0);
}
//辅助色2
CG_INLINE UIColor * AUXILIARYCOLOR2() {
    return RGBACOLOR(250, 244, 235, 1.0);
}
//成功色
CG_INLINE UIColor * SUCCESSCOLOR() {
    return HEXCOLOR(0x4CD964);
}
//警告色
CG_INLINE UIColor * WARNINGCOLOR() {
    return RGBACOLOR(230, 47, 92, 1.0);
}

CG_INLINE UIColor * SHADOWCOLOR() {
    return RGBACOLOR(0, 26, 37, 0.2);
}
// 黑色 COLOR222222
CG_INLINE UIColor * MAINCOLOR() {
    return RGBACOLOR(34, 34, 34, 1.0);
}
// 白色
CG_INLINE UIColor * COLORFFFFFF() {
    return [UIColor whiteColor];
}
// 灰色1
CG_INLINE UIColor * COLOR555555() {
    return RGBACOLOR(85, 85, 85, 1.0);
}
// 灰色2 COLOR888888
CG_INLINE UIColor * GRAYCOLOR() {
    return RGBACOLOR(136, 136, 136, 1.0);
}
//灰色2
CG_INLINE UIColor * COLOR888888() {
    return RGBACOLOR(136, 136, 136, 1.0);
}
// 灰色3
CG_INLINE UIColor * COLORCCCCCC() {
    return RGBACOLOR(204, 204, 204, 1.0);
}
//灰色4 分割线颜色
CG_INLINE UIColor * COLOREDEDED() {
    return RGBACOLOR(237, 237, 237, 1.0);
}
//键盘灰色
CG_INLINE UIColor * COLORF5F5F5() {
    return HEXCOLOR(0xF5F5F5);
}
//灰色5
CG_INLINE UIColor * COLORF9F9F9() {
    return RGBACOLOR(249, 249, 249, 1.0);
}
/// 肤色 #FAF4EB
CG_INLINE UIColor * COLORFAF4EB() {
    return HEXCOLOR(0xFAF4EB);
}
/// 地址选中红色
CG_INLINE UIColor *REDCOLOR(){
    return RGBCOLOR(230, 47, 92);
}
/// #F9F4EC
CG_INLINE UIColor * COLORF9F4EC() {
    return HEXCOLOR(0xF9F4EC);
}
/// 性别蓝色
CG_INLINE UIColor * COLOR0091FF() {
    return RGBACOLOR(0, 145, 255, 1.0);
}


#pragma mark - ——————— 其他相关 ————————



#pragma mark - ——————— 参数常量 ————————
//活动规则textView 限制字数 100
CG_INLINE NSInteger limitTextNum() {
    return 100;
}

//首页cell宽度
CG_INLINE CGFloat CellWidth() {
    return 280;
}
//首页cell首次弹出高度
CG_INLINE CGFloat CellHeight() {
    return 242;
}
//首页cell 高度
CG_INLINE CGFloat CellHeightTap() {
    return 434;
}
//cardView collectionView cell 整体增加高度
CG_INLINE CGFloat CellAddHeight() {
    return 26;
}

//发布活动 活动类型弹窗cell
CG_INLINE CGFloat TagsCellHeight() {
    return 32;
}
CG_INLINE CGFloat TagsCellHorizontalPadding() { //活动类型弹窗cell中, 文本左右内边距
    return 16;
}
CG_INLINE CGFloat TagsCellVerticalPadding() { //活动类型弹窗cell中, 文本上下内边距
    return 6;
}
CG_INLINE CGFloat TagsCellHorizontalMargin() { //活动类型弹窗cell中, 文本水平间距
    return 8;
}
CG_INLINE CGFloat TagsCellVerticalMargin() { //活动类型弹窗cell中, 文本垂直间距
    return 8;
}


#endif /* ConstantDefinition_h */
