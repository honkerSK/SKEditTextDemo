//
//  SKTextModel.m
//  xiangwan
//
//  Created by KentSun on 2019/8/27.
//  Copyright © 2019 KentSun. All rights reserved.
//

#import "SKTextModel.h"
#import "NSString+Size.h"

@implementation SKTextModel

//计算高度
- (void)setContent:(NSString *)content{
    _content = content;
    CGFloat textMaxW = nScreenWidth() - 16*2 - 8*2;
    CGFloat textMaxH = [content heightForMaxWidth:textMaxW font:FONTSIZE(16)] + 32;
    _textViewHeight = textMaxH;
    
}



@end
