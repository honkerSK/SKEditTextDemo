//
//  SKMainVC.m
//  SKEditTextDemo
//
//  Created by KentSun on 2019/11/11.
//  Copyright © 2019 KentSun. All rights reserved.
//

#import "SKMainVC.h"
#import "SKEditActivityVC.h"
#import "SKActivity.h"
@interface SKMainVC ()

@end

@implementation SKMainVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *pushBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:pushBtn];
    pushBtn.frame = CGRectMake(100 , 200, 200, 50);
    [pushBtn setTitle:@"点击进入编辑文字页面" forState:UIControlStateNormal];
    [pushBtn setTitleColor:MAINCOLOR() forState:UIControlStateNormal];
    [pushBtn setTitleColor:COLORCCCCCC() forState:UIControlStateDisabled];
    pushBtn.titleLabel.font = FONTSIZE(14);
    pushBtn.layer.cornerRadius = 20;
    pushBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
    pushBtn.layer.borderWidth =2;
    [pushBtn addTarget:self action:@selector(pushBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)pushBtnClick:(UIButton *)sender{
    SKActivity *activity = [[SKActivity alloc] init];
    SKEditActivityVC *editVC = [[SKEditActivityVC alloc] init];
    editVC.activity = activity;
    [self.navigationController pushViewController:editVC animated:YES];
}



@end
