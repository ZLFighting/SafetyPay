//
//  ZLSafetyPswView.h
//  SafetyPay
//
//  Created by ZL on 2017/4/10.
//  Copyright © 2017年 ZL. All rights reserved.
//  加密支付页面

#import <UIKit/UIKit.h>

@interface ZLSafetyPswView : UIView

/**
 *  清除密码
 */
- (void)clearUpPassword;

/**
 * 用户输入密码返回
 */
@property (nonatomic, copy) void(^passwordDidChangeBlock)(NSString *password);

@end
