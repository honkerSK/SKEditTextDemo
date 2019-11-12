//
//  SKEditTextCell.m
//  SKEditActivity
//
//  Created by KentSun on 2019/8/21.
//  Copyright © 2019 KentSun. All rights reserved.
//

//
#import "SKEditTextCell.h"
//model
#import "SKTextModel.h"

#import "NSString+Size.h"

#define textViewH 120

static int const wordCountAll = 3000; //限制总字数

@interface SKEditTextCell()<UITextViewDelegate>

@property (nonatomic ,weak) UILabel *tempL;
@property (nonatomic ,weak)  UITextView *textView;
@property (nonatomic, assign) BOOL isDrawRect;

@property (nonatomic ,weak) UIButton *upBtn;
@property (nonatomic ,weak) UIButton *downBtn;
@property (nonatomic ,weak) UIButton *deleteBtn;
//记录是否调 textViewDidEndEditing 中代码 , YES : 不调
@property (nonatomic, assign) BOOL isDeleteBtn;

//虚线边框层
@property (nonatomic, strong) CAShapeLayer *border;
//记录当前textViewHeight高度
//@property (nonatomic, assign) CGFloat textViewHeight;

@end

@implementation SKEditTextCell

- (void)setIsSkFirstResponder:(BOOL)isSkFirstResponder{
    _isSkFirstResponder = isSkFirstResponder;
    if (isSkFirstResponder) {
        [self.textView becomeFirstResponder];
    }
}

//每次编辑结束后都要全局刷新
- (void)setTextModel:(SKTextModel *)textModel{
    _textModel = textModel;
    self.textView.text = textModel.content;
    self.upBtn.enabled = textModel.upBtnEnable;
    self.downBtn.enabled = textModel.downBtnEnable;
    self.deleteBtn.enabled = textModel.deleteEnable;
    self.deleteBtn.alpha = textModel.deleteEnable ? 1.0: 0.5;
    self.wordCountLabel.text = [NSString stringWithFormat:@"%ld/%d", textModel.wordTotal, wordCountAll];
    
    CGFloat currentTextViewHeight = 0;
    if (textModel.textViewHeight > textViewH) {
        currentTextViewHeight = textModel.textViewHeight;
        [self.textView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(textModel.textViewHeight);
        }];
    }else{
        currentTextViewHeight = textViewH;
        [self.textView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(textViewH);
        }];
    }

    //画虚线边框
    //NSLog(@"self.textView.frame = %@", NSStringFromCGRect(self.textView.frame));
    CGRect bounds = CGRectMake(0, 0, nScreenWidth()-16*2, currentTextViewHeight);
    UIBezierPath *maskPath = [[UIBezierPath bezierPathWithRoundedRect:bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(8, 8)] bezierPathByReversingPath];
    self.border.frame = bounds;
    self.border.path = maskPath.CGPath;
    
}

// 虚线圆角边框 传入layer
- (void)addBorderToLayer:(UIView *)view{
    CAShapeLayer *border = [CAShapeLayer layer];
    // 线条颜色
    border.strokeColor = COLORCCCCCC().CGColor;
    border.masksToBounds = YES;
    
    border.fillColor = nil;
    border.lineWidth = 1;
    border.lineCap = @"square";
    // 第一个是 线条长度 第二个是间距 nil时为实线
    border.lineDashPattern = @[@6, @4];
    [view.layer addSublayer:border];
    self.border = border;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setup];
    }
    return self;
}

- (void)setup{
    WeakSelf
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = COLORFFFFFF();
    
    UIButton *upBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.contentView addSubview:upBtn];
    self.upBtn = upBtn;
    [upBtn setImage:[UIImage imageNamed:@"activity_up"] forState:UIControlStateNormal];
    [upBtn setImage:[UIImage imageNamed:@"activity_up_d"] forState:UIControlStateDisabled];
    [upBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(32);
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(24);
    }];
    [upBtn addTarget:self action:@selector(upBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *downBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.contentView addSubview:downBtn];
    self.downBtn = downBtn;
    [downBtn setImage:[UIImage imageNamed:@"activity_down"] forState:UIControlStateNormal];
    [downBtn setImage:[UIImage imageNamed:@"activity_down_d"] forState:UIControlStateDisabled];
    [downBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(32);
        make.top.mas_equalTo(0);
        make.left.equalTo(upBtn.mas_right).offset(16);
    }];
    [downBtn addTarget:self action:@selector(downBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.contentView addSubview:deleteBtn];
    self.deleteBtn = deleteBtn;
    [deleteBtn setImage:[UIImage imageNamed:@"activity_close"] forState:UIControlStateNormal];
    [deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(32);
        make.top.mas_equalTo(0);
        make.right.mas_equalTo(-24);
    }];
    [deleteBtn addTarget:self action:@selector(deleteBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    //自适应高度textView
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:textView];
    self.textView = textView;
    textView.font = FONTSIZE(16);
    textView.textColor = MAINCOLOR();
    textView.tintColor = MAINCOLOR();//光标颜色
    textView.backgroundColor = COLORFFFFFF();
    textView.delegate = self; // UITextViewDelegate
    //设置光标位置
    textView.textContainer.lineFragmentPadding = 0;
    textView.textContainerInset = UIEdgeInsetsMake(8, 8, 8, 8);
    textView.scrollEnabled = NO;
    
    [textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(upBtn.mas_bottom);
        make.left.mas_equalTo(16);
        make.width.mas_equalTo(nScreenWidth()-16*2);
        make.height.mas_equalTo(textViewH);
    }];
    [self addBorderToLayer:textView]; //画虚线框

    //字数统计label
    UILabel *wordCountLabel = [[UILabel alloc] init];
    [self.contentView addSubview:wordCountLabel];
    self.wordCountLabel = wordCountLabel;
//    wordCountLabel.text = [NSString stringWithFormat:@"%ld/3000", self.textModel.textNum];
    wordCountLabel.textColor = COLOR888888();
    wordCountLabel.font = FONTSIZE(14);
    wordCountLabel.textAlignment = NSTextAlignmentRight;
    wordCountLabel.hidden = YES;
    [wordCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(textView.mas_bottom).offset(4);
        make.right.mas_equalTo(-16);
        make.height.mas_equalTo(20);
        make.bottom.equalTo(weakSelf.contentView).offset(-16).priority(MASLayoutPriorityDefaultLow);
    }];
    
}

- (void)upBtnClick:(UIButton *)btn{
    [self.textView resignFirstResponder];
    if (self.upTapBlock) {
        self.upTapBlock(btn);
    }
}

- (void)downBtnClick:(UIButton *)btn{
    [self.textView resignFirstResponder];
    if (self.downTapBlock) {
        self.downTapBlock(btn);
    }
}

//结束编辑后调用
- (void)deleteBtnClick:(UIButton *)btn{
    [self.textView resignFirstResponder];
    self.isDeleteBtn = YES;
    //当前总字数
    NSInteger currentTotal = self.textModel.wordTotal -  self.textView.text.length;
    //根据字数验证是否打开 下一步按钮
    if (currentTotal > wordCountAll) {
        if (self.maxTextLengthBlock) {
            self.maxTextLengthBlock(NO);
        }
    }else{
        if (self.maxTextLengthBlock) {
            self.maxTextLengthBlock(YES);
        }
    }
    
    if (self.deleteTapBlock) {
        self.deleteTapBlock(btn, self.textModel, currentTotal);
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.textView resignFirstResponder];
}


#pragma mark ================== UITextViewDelegate ======================
//- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
//}

- (void)textViewDidChange:(UITextView *)textView{
    //保存输入内容,计算textView高度
    NSString *text = textView.text;
    //1.当前总字数
    NSInteger currentTotal = self.textModel.wordTotal - self.textModel.textNum + text.length;
    self.wordCountLabel.text = [NSString stringWithFormat:@"%ld/%d", (long)currentTotal, wordCountAll];
    if (currentTotal > wordCountAll) {
        self.wordCountLabel.textColor = WARNINGCOLOR();
        textView.textColor =  WARNINGCOLOR();
        if (self.maxTextLengthBlock) {
            self.maxTextLengthBlock(NO);
        }
        
    }else{
        self.wordCountLabel.textColor = COLOR888888();
        textView.textColor = MAINCOLOR();
        if (self.maxTextLengthBlock) {
            self.maxTextLengthBlock(YES);
        }
    }
    
    //之前的高度
    NSInteger textViewHeight = self.textModel.textViewHeight;
    self.textModel.content = text;
    //2.计算后高度
    NSInteger calcHeight = self.textModel.textViewHeight;
    if (textViewHeight != calcHeight && calcHeight > textViewH) { // 高度不一样，就改变了高度
        //高度差值
        CGFloat diffH = calcHeight - textViewHeight;
        //更新高度
//        textViewHeight = calcHeight;
        if(self.changeCellHeightBlock){
            self.changeCellHeightBlock(diffH);
        }
    }
    
}


- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
//    self.wordCountLabel.hidden = NO;
//    self.wordCountLabel.text = [NSString stringWithFormat:@"%ld/3000", self.textModel.wordTotal - self.textModel.textNum + self.textModel.content.length];
    if (self.textViewShouldBeginEditingBlock) {
        self.textViewShouldBeginEditingBlock(self);
    }
    return YES;
}


- (void)textViewDidBeginEditing:(UITextView *)textView{
    textView.backgroundColor = COLORFAF4EB();
    self.wordCountLabel.hidden = NO;
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    //总字数
    NSInteger wordTotal = self.textModel.wordTotal - self.textModel.textNum + textView.text.length;
    NSString *text = textView.text;
    self.textModel.textNum = text.length; //模型记录当前cell字数
    self.textModel.content = text;
    self.textModel.wordTotal = wordTotal;
    self.wordCountLabel.hidden = YES;
    textView.backgroundColor = COLORFFFFFF();
    //传出当前字数和标识
    if (self.wordCountBlock) {
        self.wordCountBlock(text.length, wordTotal ,self.textModel.identifierModel);
    }
}



- (void)awakeFromNib {
    [super awakeFromNib];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
}


@end
