# SafetyPay
iOS-仿京东6位密码支付输入框

开发需求中有时候我们需要用于安全支付的功能, 需要设置APP钱包的支付密码, 页面是仿照京东的6位输入框的的做法, 效果如下图:
![](https://github.com/ZLFighting/SafetyPay/blob/master/SafetyPay/47775A92-2454-45D6-8C69-054AFB968B94.png)


看起来是有由6个UITextField组成, 其实并不是，这只是一个假象.

>#### 实现思路:
1. 创建一个UITextField，仅仅一个而不是六个! 然后用5根竖线进行分割，这样我们看到的就是一个有6个等同输入框的视图.
2. 创建黑点可以通过创建一个正方形的UIView，设置圆角为宽高的一半，就是一个圆了，使其 frame 显示在中间则黑点居中即可.
3. 当点击输入时候使用shouldChangeCharactersInRange 方法来用来输入的 textfield 做处理, 是否成为第一响应者,用来用户输入, 监听其值的改变.
4. 当密码的长度达到需要的长度时,关闭第一响应者. 这里可以使用 block 来传递 password 的值.
5. 提供一个清除 password 的方法


现在核心代码如下:
#### 先抽出加密支付页面 ZLSafetyPswView, 在.m中主要就是实现页面的效果：
```
#define kDotSize CGSizeMake (10, 10) // 密码点的大小
#define kDotCount 6  // 密码个数
#define K_Field_Height self.frame.size.height  // 每一个输入框的高度等于当前view的高度

@interface ZLSafetyPswView () <UITextFieldDelegate>

// 密码输入文本框
@property (nonatomic, strong) UITextField *pswTextField;
// 用于存放加密黑色点
@property (nonatomic, strong) NSMutableArray *dotArr;

@end
```
创建分割线和黑点.
```
#pragma mark - 懒加载

- (NSMutableArray *)dotArr {
if (!_dotArr) {
_dotArr = [NSMutableArray array];

}
return _dotArr;
}
- (instancetype)initWithFrame:(CGRect)frame {

self = [super initWithFrame:frame];
if (self) {
self.backgroundColor = [UIColor whiteColor];

[self setupWithPswTextField];
}
return self;
}

- (void)setupWithPswTextField {

// 每个密码输入框的宽度
CGFloat width = self.frame.size.width / kDotCount;

// 生成分割线
for (int i = 0; i < kDotCount - 1; i++) {
UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.pswTextField.frame) + (i + 1) * width, 0, 1, K_Field_Height)];
lineView.backgroundColor = [UIColor grayColor];
[self addSubview:lineView];
}

self.dotArr = [[NSMutableArray alloc] init];

// 生成中间的黑点
for (int i = 0; i < kDotCount; i++) {
UIView *dotView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.pswTextField.frame) + (width - kDotCount) / 2 + i * width, CGRectGetMinY(self.pswTextField.frame) + (K_Field_Height - kDotSize.height) / 2, kDotSize.width, kDotSize.height)];
dotView.backgroundColor = [UIColor blackColor];
dotView.layer.cornerRadius = kDotSize.width / 2.0f;
dotView.clipsToBounds = YES;
dotView.hidden = YES; // 首先隐藏
[self addSubview:dotView];

// 把创建的黑色点加入到存放数组中
[self.dotArr addObject:dotView];
}
}
```
创建一个UITextField.切记输入的文字颜色和输入框光标的颜色为透明!
```
#pragma mark - init

- (UITextField *)pswTextField {

if (!_pswTextField) {
_pswTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, K_Field_Height)];
_pswTextField.backgroundColor = [UIColor clearColor];
// 输入的文字颜色为无色
_pswTextField.textColor = [UIColor clearColor];
// 输入框光标的颜色为无色
_pswTextField.tintColor = [UIColor clearColor];
_pswTextField.delegate = self;
_pswTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
_pswTextField.keyboardType = UIKeyboardTypeNumberPad;
_pswTextField.layer.borderColor = [[UIColor grayColor] CGColor];
_pswTextField.layer.borderWidth = 1;
[_pswTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
[self addSubview:_pswTextField];
}
return _pswTextField;
}
```
文本框内容改变时,用来用户输入, 监听其值的改变.
```
#pragma mark - 文本框内容改变

/**
*  重置显示的点
*/
- (void)textFieldDidChange:(UITextField *)textField {

NSLog(@"目前输入显示----%@", textField.text);

for (UIView *dotView in self.dotArr) {
dotView.hidden = YES;
}
for (int i = 0; i < textField.text.length; i++) {
((UIView *)[self.dotArr objectAtIndex:i]).hidden = NO;
}
if (textField.text.length == kDotCount) {
NSLog(@"---输入完毕---");

[self.pswTextField resignFirstResponder];
}

// 获取用户输入密码
!self.passwordDidChangeBlock ? : self.passwordDidChangeBlock(textField.text);
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {

NSLog(@"输入变化%@", string);
if([string isEqualToString:@"\n"]) { // 按回车关闭键盘

[textField resignFirstResponder];
return NO;
} else if(string.length == 0) { // 判断是不是删除键

return YES;
} else if(textField.text.length >= kDotCount) { // 输入的字符个数大于6，则无法继续输入，返回NO表示禁止输入

NSLog(@"输入的字符个数大于6，后面禁止输入则忽略输入");
return NO;
} else {

return YES;
}
}
```
清除密码时收起键盘并将文本输入框值置为空.
```
#pragma mark - publick method

/**
*  清除密码
*/
- (void)clearUpPassword {
[self.pswTextField resignFirstResponder];
self.pswTextField.text = nil;
[self textFieldDidChange:self.pswTextField];
}
```

#### 接着在当前所需控制器里,创建支付页面并拿到用户输入密码去做支付相关逻辑处理
```
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
```
方便测试加上清空密码按钮
```
// 清空密码
- (void)clearPsw {

[self.pswView clearUpPassword];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
[self.view endEditing:YES];
}
```

我这里是做6位支付密码的, 你同样可以修改kDotCount密码个数值,目前也有4位的.

您的支持是作为程序媛的我最大的动力, 如果觉得对你有帮助请送个Star吧,谢谢啦
