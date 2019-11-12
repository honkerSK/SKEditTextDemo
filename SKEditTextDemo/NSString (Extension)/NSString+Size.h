//
//  NSString+Size.h
//  SKEditTextDemo
//
//  Created by KentSun on 2019/4/10.
//  Copyright © 2019年 KentSun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Size)

-(CGFloat)widthForMaxHeight:(CGFloat)maxHeight fontSize:(CGFloat)fontSize;
-(CGFloat)heightForMaxWidth:(CGFloat)maxWidth fontSize:(CGFloat)fontSize;

-(CGFloat)heightForMaxWidth:(CGFloat)maxWidth font:(UIFont *)font;
-(CGFloat)widthForMaxHeight:(CGFloat)maxHeight font:(UIFont *)font;


-(CGFloat)heightHTMLForMaxWidth:(CGFloat)maxWidth font:(UIFont *)font;
-(CGFloat)heightHTMLForMaxWidth:(CGFloat)maxWidth attr:(NSAttributedString *)attr;

@end
