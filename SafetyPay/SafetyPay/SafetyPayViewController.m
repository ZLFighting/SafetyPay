//
//  ViewController.m
//  SafetyPay
//
//  Created by ZL on 2017/4/10.
//  Copyright © 2017年 ZL. All rights reserved.
//

#import "SafetyPayViewController.h"
#import "ZLSafetyPswView.h"

@interface SafetyPayViewController ()

@property (nonatomic, strong) ZLSafetyPswView *pswView;

@end

@implementation SafetyPayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"安全支付";
    self.view.backgroundColor = [UIColor colorWithRed:230 / 250.0 green:230 / 250.0 blue:230 / 250.0 alpha:1.0];
    
    // 加密支付页面
    ZLSafetyPswView *pswView = [[ZLSafetyPswView alloc] initWithFrame:CGRectMake(50, 100, self.view.frame.size.width - 100, 45)];
    [self.view addSubview:pswView];
    self.pswView = pswView;
    pswView.passwordDidChangeBlock = ^(NSString *password) {
        NSLog(@"---用户输入密码为: %@",password);
    };
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor orangeColor];
    button.frame = CGRectMake(100, 280, self.view.frame.size.width - 200, 50);
    [button addTarget:self action:@selector(clearPsw) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"清空密码" forState:UIControlStateNormal];
    [self.view addSubview:button];
}

// 清空密码
- (void)clearPsw {
    
    [self.pswView clearUpPassword];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
