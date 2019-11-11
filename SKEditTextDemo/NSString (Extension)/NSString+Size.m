//
//  NSString+Size.m
//  CQ_App
//
//  Created by Nemo on 2019/4/10.
//  Copyright © 2019年 mac. All rights reserved.
//

#import "NSString+Size.h"

@implementation NSString (Size)

-(CGFloat)heightForMaxWidth:(CGFloat)maxWidth fontSize:(CGFloat)fontSize{
    
    return [self sizeForMaxWidth:maxWidth maxHeight:CGFLOAT_MAX font:FONTSIZE(fontSize)].height;
}

-(CGFloat)heightForMaxWidth:(CGFloat)maxWidth font:(UIFont *)font{
    return [self sizeForMaxWidth:maxWidth maxHeight:CGFLOAT_MAX font:font].height;
}

-(CGFloat)heightHTMLForMaxWidth:(CGFloat)maxWidth attr:(NSAttributedString *)attr {
    if (!attr) {
        return 0;
    }
    CGSize textSize = [attr boundingRectWithSize:(CGSize){maxWidth, CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading context:nil].size;
    return textSize.height;
}

-(CGFloat)heightHTMLForMaxWidth:(CGFloat)maxWidth font:(UIFont *)font {

    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithData:[self dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute:[NSNumber numberWithInt:NSUTF8StringEncoding]} documentAttributes:nil error:nil];
    CGSize textSize = [attributedString boundingRectWithSize:(CGSize){maxWidth, CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading context:nil].size;
    
    return textSize.height;
}

-(CGFloat)widthForMaxHeight:(CGFloat)maxHeight fontSize:(CGFloat)fontSize{
    
    return [self sizeForMaxWidth:CGFLOAT_MAX maxHeight:maxHeight font:FONTSIZE(fontSize)].width;
}

-(CGFloat)widthForMaxHeight:(CGFloat)maxHeight font:(UIFont *)font {
    return [self sizeForMaxWidth:CGFLOAT_MAX maxHeight:maxHeight font:font].width;
}

-(CGSize)sizeForMaxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight font:(UIFont *)font{
    CGSize textBlockMinSize = {maxWidth, maxHeight};
    CGSize size;
    static float systemVersion;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    });
    
    if (systemVersion >= 7.0) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineSpacing:0];//调整行间距，默认为0
        [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
        size = [self boundingRectWithSize:textBlockMinSize options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                  attributes:@{
                                               NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle
                                               }
                                     context:nil].size;
    }else{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        size = [self sizeWithFont:font
                constrainedToSize:textBlockMinSize
                    lineBreakMode:NSLineBreakByCharWrapping];
#pragma clang diagnostic pop

    }

    return size;
}

@end
