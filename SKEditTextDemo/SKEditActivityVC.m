//
//  SKEditActivityVC.m
//  xiangwan
//
//  Created by KentSun on 2019/8/21.
//  Copyright © 2019 KentSun. All rights reserved.
//

/*
 字数统计思路
 1.创建模型时候, 给cell对应 模型一个时间戳标识
 2 控制器使用字典属性, 保存所有cell 对应字数
 3.根据标识存值 取值, 当前的textview 字数
 4.编辑时,  (显示总数 = 模型总字数 - 模型中当前cell字数 + 当前textfield中字数)
 5.结束编辑时, cell 传给控制器 标识,当前cell字数和 总字数 (总数 = 模型总字数 - 模型中当前cell字数 + 当前textfield中字数)
 6.控制器 用字典保存当前cell字数, 保存总字数
 7.结束编辑时, 刷新所有cell, 给每个cell模型重新赋值 总字数和当前cell字数
 8.当前cell删除, 总数 - 当前cell文字总数 , 刷新
 */

#import "SKEditActivityVC.h"

//cell
#import "SKEditTextCell.h"
//model
#import "SKActivity.h"
#import "SKTextModel.h"
//Vendors
#import "UIView+SKContinueFirstResponder.h"

static NSString *const editTextCellId = @"SKEditTextCell";
static int const wordCountAll = 3000; //限制总字数
//做动画类型
typedef NS_ENUM(NSInteger, SKExchangeCellAnimationType) {
    SKExchangeCellAnimationDown,
    SKExchangeCellAnimationUp
};

@interface SKEditActivityVC ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic ,weak) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic ,weak) UIButton *insetTextBtn;
@property (nonatomic ,weak) UIView *bottomView;
@property (nonatomic ,weak) UIButton *nextBtn;

///保存所有文字总字数字典 { SKTextModel%@ : @"每个cell字数" }
@property (nonatomic, strong) NSMutableDictionary *wordTotalDict;
///获取所有总字数
@property (nonatomic, assign) NSInteger wordTotal;
///保存上一个正在编辑cell
@property (nonatomic ,weak) SKEditTextCell *editingTextCell;
///记录是否超过限制字数, YES: 没有超, NO:超过限制字数
@property (nonatomic, assign) BOOL isLimitWord;

//缓存高度
@property (nonatomic, strong) NSMutableDictionary *cellHightDict;

@end

@implementation SKEditActivityVC

#pragma mark ================== lazy  ======================

- (NSMutableArray *)dataSource{
    if (_dataSource == nil) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

- (NSMutableDictionary *)wordTotalDict{
    if (_wordTotalDict == nil) {
        _wordTotalDict = [NSMutableDictionary dictionary];
    }
    return _wordTotalDict;
}

//加载已有活动数据
- (void)loadData{
    NSMutableArray *content = self.activity.content;
    if (content.count == 0) {
        //默认插入一个文本cell
        [self insetText:nil];
        return;
    }
    
    NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:content.count];
    for (NSDictionary *dict in content) {
        NSInteger type = [dict[@"type"] integerValue];
        if (type == 0) {
            SKTextModel *textModel = [[SKTextModel alloc] init];
            [textModel mj_setKeyValues:dict];
            [tempArr addObject:textModel];
            
            //字典wordTotalDict 获取数据,累加总字数
            NSDate *dat = [NSDate dateWithTimeIntervalSinceNow:0];
            NSTimeInterval a = [dat timeIntervalSince1970];
            NSString *timeString = [NSString stringWithFormat:@"%.f", a];
            textModel.identifierModel = [NSString stringWithFormat:@"SKTextModel%@", timeString];
            NSInteger textNum = textModel.content.length;
            self.wordTotal += textNum;
            self.wordTotalDict[textModel.identifierModel] = [NSString stringWithFormat:@"%ld", (long)textNum];
        }
    }
    self.dataSource = tempArr;
    [self.tableView reloadData];
}


#pragma mark ================== view life  ======================
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = COLORFFFFFF();
    [self setupNav];
    [self setupTableView];
    [self setupBottomView];
//    self.wordTotalCount = 0;
    //加载数据
    [self loadData];
    self.isLimitWord = (self.wordTotal <= wordCountAll); //是否达到总字数
    [self verifyNextBtn];
    
    //先添加对键盘的监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrameNotification:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark ================== setupUI ======================
- (void)setupNav{
    self.title = @"自动调整高度TextCell";
    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    saveBtn.frame = CGRectMake(0, 0, 30, 20);
    [saveBtn setTitle:@"保存" forState:UIControlStateNormal];
    [saveBtn setTitleColor:MAINCOLOR() forState:UIControlStateNormal];
    [saveBtn setTitleColor:COLORCCCCCC() forState:UIControlStateDisabled];
    saveBtn.titleLabel.font = FONTSIZE(14);
    saveBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [saveBtn addTarget:self action:@selector(saveAlert) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithCustomView:saveBtn];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 24, 24);
    [backBtn setImage:[UIImage imageNamed:@"public_back"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(leftBackAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithCustomView:backBtn];
    
}

- (void)setupBottomView{
    UIView *bottomView = [[UIView alloc] init];
    bottomView.backgroundColor = COLORFFFFFF();
    [self.view addSubview:bottomView];
    self.bottomView = bottomView;
    bottomView.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:26/255.0 blue:37/255.0 alpha:1.0].CGColor;
    bottomView.layer.shadowOffset = CGSizeMake(0,10);
    bottomView.layer.shadowOpacity = 0.8;
    bottomView.layer.shadowRadius = 10;
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(66+kSafeAreaBottomHeight);
        make.bottom.left.right.mas_equalTo(0);
    }];
    
    UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [bottomView addSubview:nextBtn];
    self.nextBtn = nextBtn;
    [nextBtn setTitle:@"下一步" forState:UIControlStateNormal];
    [nextBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [nextBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    nextBtn.titleLabel.font = FONTBOLDSIZE(16);
    nextBtn.layer.borderWidth = 2;
//    nextBtn.layer.borderColor = [UIColor greenColor].CGColor;
    nextBtn.layer.cornerRadius = 20;
    nextBtn.enabled = NO;
    nextBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [nextBtn addTarget:self action:@selector(nextBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    [nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(8);
        make.right.mas_equalTo(-16);
        make.width.mas_equalTo(96);
        make.height.mas_equalTo(48);
    }];
    
}

- (void)setupTableView{
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.view addSubview:tableView];
    self.tableView = tableView;
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.estimatedRowHeight = 120;
    tableView.rowHeight = UITableViewAutomaticDimension;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone; //去掉分割线
//    tableView.contentInset = UIEdgeInsetsMake(0, 0, picUploadViewH + 66+kSafeAreaBottomHeight, 0); // uploadView 高度 + bottomViewH
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(kStatusBarAndNavigationBarHeight);
        make.left.right.mas_equalTo(0);
//        make.bottom.equalTo(weakSelf.bottomView.mas_top);
        make.bottom.mas_equalTo(0);
    }];
    [tableView registerClass:[SKEditTextCell class] forCellReuseIdentifier:editTextCellId];
    tableView.tableFooterView = [self getFooterView];
    
}
// 添加tableFooterView
- (UIView *)getFooterView{
    UIView *footerView = [UIView new];
    footerView.backgroundColor = COLORFFFFFF();
    footerView.frame = CGRectMake(0, 0, nScreenWidth(), kKeyboardHeight()+40); //高度为 键盘高度
    
    //顶部 分割线
    UIBezierPath *linePath = [UIBezierPath bezierPath];  // 线的路径
    [linePath moveToPoint:CGPointMake(0, 0)]; // 起点
    [linePath addLineToPoint:CGPointMake(nScreenWidth(), 0)]; //终点
    CAShapeLayer *lineLayer = [CAShapeLayer layer];
    lineLayer.lineWidth = 1;
    lineLayer.strokeColor = COLOREDEDED().CGColor;
    lineLayer.path = linePath.CGPath;
    lineLayer.fillColor = nil; // 默认为blackColor
    [footerView.layer addSublayer:lineLayer];
    
    //插入按钮
    CGFloat btnY = 16;
    CGFloat btnW = 140;
    CGFloat btnH = 40;
    UIButton *insetTextBtn = [self creatInsetBtn:@"插入文字" picName:@"activity_add_text"];
    insetTextBtn.frame = CGRectMake(nScreenWidth() * 0.5 + 8, btnY, btnW, btnH);
    [footerView addSubview:insetTextBtn];
    self.insetTextBtn = insetTextBtn;
    [insetTextBtn addTarget:self action:@selector(insetText:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *textLabel = [[UILabel alloc] init];
    [footerView addSubview:textLabel];
    textLabel.text = @"最多可以输入3000字";
    textLabel.textColor = COLOR888888();
    textLabel.font = FONTSIZE(12);
    [textLabel sizeToFit];
    textLabel.center = CGPointMake(insetTextBtn.center.x, insetTextBtn.center.y + btnH *0.5 + 16);
    
    return footerView;
}


#pragma mark ================== UITableViewDataSource ======================
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    WeakSelf
    UITableViewCell *cell;
    NSObject *obj = self.dataSource[indexPath.row];
    
    if ([obj isKindOfClass:[SKTextModel class]]) {
        SKEditTextCell *textCell = (SKEditTextCell *)[tableView dequeueReusableCellWithIdentifier:editTextCellId forIndexPath:indexPath];
        
        SKTextModel *textModel = (SKTextModel *)obj;
        textModel.upBtnEnable = (indexPath.row == 0)? NO: YES;
        textModel.downBtnEnable = (indexPath.row == self.dataSource.count - 1)? NO: YES;
        
        textModel.wordTotal = self.wordTotal; //每次刷新 模型赋值总字数
        NSString *identifierModel = textModel.identifierModel;
        textModel.textNum = [self.wordTotalDict[identifierModel] integerValue]; //取出对应字数
        //如果只有一个SKEditTextCell, 置灰删除按钮
        textModel.deleteEnable =  (self.dataSource.count == 1) ? NO: YES;
        textCell.textModel = textModel;
        
        __weak SKEditTextCell *weakEditCell = textCell;
        textCell.upTapBlock = ^(UIButton *sender) {
            if (indexPath.row == 0) return ;
            [weakSelf textCellUpTap:indexPath editCell:weakEditCell];
        };
        
        textCell.downTapBlock = ^(UIButton *sender) {
            if (indexPath.row == weakSelf.dataSource.count - 1) {
                return ;
            }
            [weakSelf textCellDownTap:indexPath editCell:weakEditCell];
        };
        
        textCell.deleteTapBlock = ^(UIButton * _Nonnull sender, SKTextModel * _Nonnull textModel, NSInteger wordTotal) {
            sender.enabled = NO;
            [weakSelf.dataSource removeObject:textModel];
            [weakSelf.wordTotalDict removeObjectForKey:textModel.identifierModel]; //删除记录字数键值对
            weakSelf.wordTotal = wordTotal;//重新计算总数
            
            NSIndexPath *deleteIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
            //方案一: 连点击删除按钮, index出错闪退
//            [weakSelf.tableView deleteRowsAtIndexPaths:@[deleteIndexPath] withRowAnimation:UITableViewRowAnimationNone];
//            [weakSelf.tableView reloadData];
//            sender.enabled = YES;
//            [weakSelf verifyNextBtn];
            
            //方案二:
            [CATransaction begin];
            [CATransaction setCompletionBlock:^{
                [weakSelf.tableView reloadData];
                sender.enabled = YES;
                [weakSelf verifyNextBtn];
                //校验是否打开插入文本
//                [weakSelf verifyInsetTextBtn];
            }];
            [weakSelf.tableView beginUpdates];
            [weakSelf.tableView deleteRowsAtIndexPaths:@[deleteIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            [weakSelf.tableView endUpdates];
            [CATransaction commit];
        };
        
        textCell.changeCellHeightBlock = ^(CGFloat diffHeight) {
            //刷新高度,键盘不退出
            [weakSelf.tableView skContinueFirstResponderAndExecuteCode:^(UIViewResponderHelper *nextResponder) {
                NSIndexPath *sourceIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
                [weakSelf.tableView reloadRowsAtIndexPaths:@[sourceIndexPath] withRowAnimation:UITableViewRowAnimationNone];
                //tableView移动高度差距离
                CGFloat currentOffsetY = weakSelf.tableView.contentOffset.y;
                [weakSelf.tableView setContentOffset:CGPointMake(0, currentOffsetY+ diffHeight) animated:YES];
                //指定响应的textCell
                nextResponder.nextFirstResponderIndex = indexPath.row;
            }];
        };
        
        //将要开始编辑,滚动到对应cell
        textCell.textViewShouldBeginEditingBlock = ^(SKEditTextCell * _Nonnull cell) {
//        [weakSelf.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            weakSelf.editingTextCell = cell;//保存正在编辑的cell
        };
        
        //将要结束编辑的回调
        textCell.wordCountBlock = ^(NSInteger textNum, NSInteger wordTotal, NSString * _Nonnull identifierModel) {
            //更改对应字数
            weakSelf.wordTotalDict[identifierModel] = [NSString stringWithFormat:@"%ld", (long)textNum];
            weakSelf.wordTotal = wordTotal;
            //[weakSelf.tableView reloadRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationNone];
//            [weakSelf verifyInsetTextBtn];
            [weakSelf.tableView reloadData];
            [weakSelf verifyNextBtn];
        };
        
        textCell.maxTextLengthBlock = ^(BOOL isEnable) {
            //记录是否超过字数 isEnable YES: 没有超, NO:超过限制字数
            weakSelf.isLimitWord = isEnable;
            [weakSelf verifyNextBtn];
        };
        
        cell = textCell;
        
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


//缓存高度 ,解决刷新tableView 跳动问题
- (NSMutableDictionary *)cellHightDict {
    if (!_cellHightDict) {
        _cellHightDict = [NSMutableDictionary new];
    }
    return _cellHightDict;
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSNumber *height = @(cell.frame.size.height);
    [self.cellHightDict setObject:height forKey:indexPath];
}
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSNumber *height = [self.cellHightDict objectForKey:indexPath];
    if(height){
        return height.floatValue;
    }else{
        return 120;
    }
}


#pragma mark 点击文字向上按钮 动画
- (void)textCellUpTap:(NSIndexPath *)indexPath editCell:(SKEditTextCell *)weakEditCell{
    WeakSelf
    //sourceIndexPath是被点击cell的IndexPath
    NSIndexPath *sourceIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
    NSIndexPath *destinationIndexPath = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:0];
    
    //NSLog(@"sourceIndexPath = %ld ,destinationIndexPath = %ld ", (long)indexPath.row , indexPath.row - 1);
    [self.dataSource exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:destinationIndexPath.row];
    //方案一 直接刷新
//    [self.tableView exchangeSubviewAtIndex:indexPath.row withSubviewAtIndex:indexPath.row -1];
//    [self.tableView reloadRowsAtIndexPaths:@[sourceIndexPath,destinationIndexPath] withRowAnimation:UITableViewRowAnimationNone];

    //方案二: 推迟更新动画，直到移动完成
//    [CATransaction begin];
//    [CATransaction setCompletionBlock:^{
//        [weakSelf.tableView reloadRowsAtIndexPaths:@[sourceIndexPath,destinationIndexPath] withRowAnimation:UITableViewRowAnimationNone];
//    }];
//    [weakSelf.tableView beginUpdates];
//    //[weakSelf.tableView moveRowAtIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];
//    [weakSelf.tableView exchangeSubviewAtIndex:indexPath.row withSubviewAtIndex:indexPath.row -1];
//    [weakSelf.tableView endUpdates];
//    [CATransaction commit];
    
//    CGFloat cellY = weakEditCell.frame.origin.y;
//    UITableViewCell *nextCell = [weakSelf.tableView cellForRowAtIndexPath:destinationIndexPath];
//    [UIView animateWithDuration:0.6 animations:^{
//        //当前这个顶部就和上面一个平齐
//        CGRect rect = weakEditCell.frame;
//        rect.origin.y = cellY - CGRectGetHeight(nextCell.frame);
//        weakEditCell.frame = rect;
//        //上面一个需要处理一下,只能基于当前的y+下面的cell的高度,直接交换y轴,位置不准,在刷新表格的时候,会有抖动的现象
//        CGRect rect1 = nextCell.frame;
//        rect1.origin.y = cellY;
//        nextCell.frame = rect1;
//    } completion:^(BOOL finished) {
//        [weakSelf.tableView reloadRowsAtIndexPaths:@[sourceIndexPath,destinationIndexPath] withRowAnimation:UITableViewRowAnimationNone];
//        //[weakSelf.tableView reloadData];
//    }];
    
     [self exchangeCellAnimationWithCell:weakEditCell sourceIndexPath:sourceIndexPath destinationIndexPath:destinationIndexPath animationType:SKExchangeCellAnimationUp];
}


#pragma mark 点击文字向下按钮 动画
- (void)textCellDownTap:(NSIndexPath *)indexPath editCell:(SKEditTextCell *)weakEditCell{
    WeakSelf
    //sourceIndexPath是被点击cell的IndexPath
    NSIndexPath *sourceIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
    NSIndexPath *destinationIndexPath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:0];
    [self.dataSource exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:destinationIndexPath.row];
    
    //方案一:
//    [self.tableView exchangeSubviewAtIndex:indexPath.row withSubviewAtIndex:indexPath.row + 1];
//    [self.tableView reloadRowsAtIndexPaths:@[sourceIndexPath,destinationIndexPath] withRowAnimation:UITableViewRowAnimationNone];
    
    //方案二:推迟更新动画，直到移动完成
//    [CATransaction begin];
//    [CATransaction setCompletionBlock:^{
//        [weakSelf.tableView reloadRowsAtIndexPaths:@[sourceIndexPath,destinationIndexPath] withRowAnimation:UITableViewRowAnimationNone];
//    }];
//    [weakSelf.tableView beginUpdates];
//    //[weakSelf.tableView moveRowAtIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];
//    [weakSelf.tableView exchangeSubviewAtIndex:indexPath.row withSubviewAtIndex:indexPath.row + 1];
//    [weakSelf.tableView endUpdates];
//    [CATransaction commit];
    
    //方案三
//    CGFloat cellY = weakEditCell.frame.origin.y;
//    UITableViewCell *nextCell = [weakSelf.tableView cellForRowAtIndexPath:destinationIndexPath];
//    [UIView animateWithDuration:0.6 animations:^{
//        //当前这个顶部就和上面一个平齐
//        CGRect rect = weakEditCell.frame;
//        rect.origin.y = cellY + CGRectGetHeight(nextCell.frame);
//        weakEditCell.frame = rect;
//        //上面一个需要处理一下,只能基于当前的y+下面的cell的高度,直接交换y轴,位置不准,在刷新表格的时候,会有抖动的现象
//        CGRect rect1 = nextCell.frame;
//        rect1.origin.y = cellY;
//        nextCell.frame = rect1;
//    } completion:^(BOOL finished) {
//        [weakSelf.tableView reloadRowsAtIndexPaths:@[sourceIndexPath,destinationIndexPath] withRowAnimation:UITableViewRowAnimationNone];
//        //[weakSelf.tableView reloadData];
//    }];
    [self exchangeCellAnimationWithCell:weakEditCell sourceIndexPath:sourceIndexPath destinationIndexPath:destinationIndexPath animationType:SKExchangeCellAnimationDown];
    
}


#pragma mark cell上下交换动画
/**
 cell上下交换动画

 @param cell 做动画的cell
 @param sourceIndexPath 该cell动画前 index
 @param destinationIndexPath 该cell动画后 index
 @param animationType 动画类型
 */
- (void)exchangeCellAnimationWithCell:(UITableViewCell *)cell sourceIndexPath:(NSIndexPath *)sourceIndexPath destinationIndexPath:(NSIndexPath *)destinationIndexPath animationType:(SKExchangeCellAnimationType)animationType{
    WeakSelf
    CGFloat cellY = cell.frame.origin.y;
    UITableViewCell *nextCell = [self.tableView cellForRowAtIndexPath:destinationIndexPath];
    [UIView animateWithDuration:0.4 animations:^{
        //当前这个顶部就和上面一个平齐
        CGRect rect = cell.frame;
        //将要交换cell高度
        CGFloat nextCellH = CGRectGetHeight(nextCell.frame);
        nextCellH = (animationType == SKExchangeCellAnimationDown) ? nextCellH : -nextCellH; //向下+ , 向上-
        rect.origin.y = cellY + nextCellH;
        cell.frame = rect;
        //上面一个需要处理一下,只能基于当前的y+下面的cell的高度,直接交换y轴,位置不准,在刷新表格的时候,会有抖动的现象
        CGRect rectTemp = nextCell.frame;
        rectTemp.origin.y = cellY;
        nextCell.frame = rectTemp;
    } completion:^(BOOL finished) {
        [weakSelf.tableView reloadRowsAtIndexPaths:@[sourceIndexPath,destinationIndexPath] withRowAnimation:UITableViewRowAnimationNone];
        //[weakSelf.tableView reloadData];
    }];
    
}



#pragma mark ================== 响应处理 ======================
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}


#pragma mark 返回按钮
- (void)leftBackAction:(UIButton *)sender{
    self.activity.content = [self getActivityContent];
    [self.navigationController popViewControllerAnimated:YES];
}


// 创建插入按钮
- (UIButton *)creatInsetBtn:(NSString *)title picName:(NSString *)picName{
    UIButton *insetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [insetBtn setBackgroundColor:COLORF9F9F9()];
    [insetBtn setImage:[UIImage imageNamed:picName] forState:UIControlStateNormal];
    [insetBtn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_d", picName]] forState:UIControlStateDisabled];
    [insetBtn setTitle:title forState:UIControlStateNormal];
    [insetBtn setTitleColor:MAINCOLOR() forState:UIControlStateNormal];
    [insetBtn setTitleColor:COLORCCCCCC() forState:UIControlStateDisabled];

    insetBtn.titleLabel.font = FONTSIZE(14);
    insetBtn.layer.cornerRadius = 16;
    insetBtn.layer.borderColor = COLOREDEDED().CGColor;
    insetBtn.layer.borderWidth = 1;
    insetBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 4);
    return insetBtn;
}

#pragma mark  插入文本
- (void)insetText:(UIButton *)sender{
    WeakSelf
    [self.view endEditing:YES];
    
    //验证是否有空的SKEditTextCell
    int i = 0;
    for (SKTextModel *textModel  in self.dataSource) {
        NSString *content = textModel.content;
        if (content.length == 0) {
            NSIndexPath *currentIndex = [NSIndexPath indexPathForRow:i inSection:0];
            SKEditTextCell *cell = (SKEditTextCell *)[self.tableView cellForRowAtIndexPath:currentIndex];
            if (cell == nil) {
                [self.tableView scrollToRowAtIndexPath:currentIndex atScrollPosition:UITableViewScrollPositionNone animated:NO];
                SKEditTextCell *currentCell = (SKEditTextCell *)[self.tableView cellForRowAtIndexPath:currentIndex];
                currentCell.isSkFirstResponder = YES;
            }else{
                cell.isSkFirstResponder = YES;
            }
            return;
        }
        i++;
    }
    
    SKTextModel *textModel = [[SKTextModel alloc] init];
    textModel.upBtnEnable = YES;
    textModel.downBtnEnable = YES;
    [self.dataSource addObject:textModel];
    
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.dataSource.count-1 inSection:0];
    [indexPaths addObject: indexPath];
    
    //赋值标识 时间戳
    NSDate *dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a = [dat timeIntervalSince1970];
    NSString *timeString = [NSString stringWithFormat:@"%.f", a];
    textModel.identifierModel = [NSString stringWithFormat:@"SKTextModel%@", timeString];
    
    textModel.wordTotal = self.wordTotal;
 
    // 向数据源中添加数据
    [weakSelf.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    [weakSelf.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    
}


#pragma mark 校验是否打开nextbtn
- (void)verifyNextBtn{
    WeakSelf
    //判断条件:有一张上传图片(并且所有图片都上传成功), 或者有2个以上文字 , 并且没有达到限制字数 既可以下一步
    //达到字数限制, 关闭下一步
    BOOL nextBtnEnable;
    if (weakSelf.dataSource.count == 0){ //没有子控件
        nextBtnEnable = NO;
        weakSelf.nextBtn.enabled = nextBtnEnable;
        weakSelf.nextBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
        return;
    }
    
    //判断 总字数是否大于2 && 有没有超总字数
    BOOL textEnable = (weakSelf.wordTotal >= 2) && (weakSelf.wordTotal <= wordCountAll);
    nextBtnEnable = textEnable ;
    weakSelf.nextBtn.enabled = nextBtnEnable;
    weakSelf.nextBtn.layer.borderColor = nextBtnEnable ?[UIColor greenColor].CGColor:[UIColor lightGrayColor].CGColor;

}

/// 保存弹窗
- (void)saveAlert{
    NSLog(@"点击保存按钮");
    [self.navigationController popToRootViewControllerAnimated:NO];
    
}

/// 点击下一步按钮
- (void)nextBtnClick{
    NSLog(@"点击下一步按钮");
}



#pragma mark ================== 监听键盘弹出 ======================
/**
 键盘将要隐藏的代理方法
 */
- (void)keyboardWillHideNotification:(NSNotification *)notification{
    WeakSelf
    // 获得键盘动画时长
    [weakSelf.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
}
- (void)keyboardWillChangeFrameNotification:(NSNotification *)notification{
    WeakSelf
    NSDictionary * userInfo = [notification userInfo];
    //UIKeyboardFrameEndUserInfoKey 用来获取键盘弹出后的高度，宽度
    CGRect rect = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGFloat keyboardHeight = CGRectGetHeight(rect) + kStatusBarAndNavigationBarHeight;
    CGFloat keyboardMinY   = nScreenHeight()-keyboardHeight;
    
    CGFloat y = 0;
    CGFloat maxY = CGRectGetMaxY(weakSelf.editingTextCell.frame); //获取正在编辑cell的frame
    if (maxY > keyboardMinY) {
        y = maxY - keyboardMinY + 40;
    }
    [weakSelf.tableView setContentOffset:CGPointMake(0, y) animated:YES];
    }


#pragma mark 根据模型数组dataSource 获取活动content
- (NSMutableArray *)getActivityContent{
    NSMutableArray *tempArrM = [NSMutableArray array];
    [self.dataSource enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[SKTextModel class]]) {
            
            SKTextModel *textModel = (SKTextModel *)obj;
            if (textModel.content.length == 0) {
                return ; //继续下一次
            }
            NSDictionary *dict = @{@"content": textModel.content, @"type":@(0)};
            [tempArrM addObject:dict];
        }
    }];
    return tempArrM;
}



/*
- (void)transformView:(NSNotification *)notify {
    WeakSelf
    //获取键盘弹出前的Rect
    NSValue *keyBoardBeginBounds = [notify.userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect beginRect = [keyBoardBeginBounds CGRectValue];
    
    //获取键盘弹出后的Rect
    NSValue *keyBoardEndBounds = [notify.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect  endRect = [keyBoardEndBounds CGRectValue];
    
    //获取键盘位置变化前后纵坐标Y的变化值
    CGFloat deltaY = endRect.origin.y - beginRect.origin.y;
    //NSLog(@"看看这个变化的Y值:%f",deltaY);//负数弹出, 正数收起
    if(deltaY < 0){
        self.tableView.hintKeyboard = YES;
        self.bottomView.hidden = YES;
    }else{
        self.bottomView.hidden = NO;
    }
    
//    if (self.fieldType == SKFieldTypeText) return;
    CGFloat duration = [[notify.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    //    CGFloat duration = [notify.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    //在0.25s内完成self.view的Frame的变化，等于是给self.view添加一个向上移动deltaY的动画
    [UIView animateWithDuration:duration animations:^{
        [weakSelf.view setFrame:CGRectMake(weakSelf.view.frame.origin.x, weakSelf.view.frame.origin.y+deltaY, weakSelf.view.frame.size.width, weakSelf.view.frame.size.height)];
    }];
}
*/


@end
