// BEGINNER GUIDE:
// File: RegisterViewController.m
// Role: UI layer: builds screens, handles taps, and calls services.
// Reading tip: Read declarations in .h first, then implementation flow in .m.

// XindongrijiApp RegisterViewController.m
#import "RegisterViewController.h"
#import "Network/HTTPClient.h"
#import "Utils/FormValidator.h"
#import "Utils/ToastUtils.h"

@interface RegisterViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *phoneField;
@property (nonatomic, strong) UITextField *passwordField;
@property (nonatomic, strong) UITextField *confirmPasswordField;

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"注册账号";
    self.view.backgroundColor = [UIColor colorWithRed:1.0 green:0.97 blue:0.98 alpha:1.0];

    [self buildUI];
}

- (void)buildUI {
    UIView *card = [[UIView alloc] init];
    card.translatesAutoresizingMaskIntoConstraints = NO;
    card.backgroundColor = UIColor.whiteColor;
    card.layer.cornerRadius = 16;
    card.layer.shadowColor = UIColor.blackColor.CGColor;
    card.layer.shadowOpacity = 0.08;
    card.layer.shadowOffset = CGSizeMake(0, 8);
    card.layer.shadowRadius = 20;
    [self.view addSubview:card];

    self.phoneField = [self textFieldWithPlaceholder:@"手机号（11位）"];
    self.phoneField.keyboardType = UIKeyboardTypeNumberPad;
    self.phoneField.delegate = self;

    self.passwordField = [self textFieldWithPlaceholder:@"密码（6-16位）"];
    self.passwordField.secureTextEntry = YES;

    self.confirmPasswordField = [self textFieldWithPlaceholder:@"确认密码"];
    self.confirmPasswordField.secureTextEntry = YES;

    UIButton *registerButton = [UIButton buttonWithType:UIButtonTypeSystem];
    registerButton.translatesAutoresizingMaskIntoConstraints = NO;
    registerButton.backgroundColor = [UIColor colorWithRed:0.94 green:0.32 blue:0.52 alpha:1.0];
    registerButton.layer.cornerRadius = 10;
    [registerButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    registerButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    [registerButton setTitle:@"注册" forState:UIControlStateNormal];
    [registerButton addTarget:self action:@selector(registerTapped) forControlEvents:UIControlEventTouchUpInside];

    UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:@[self.phoneField, self.passwordField, self.confirmPasswordField, registerButton]];
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 14;
    [card addSubview:stack];

    [NSLayoutConstraint activateConstraints:@[
        [card.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:30],
        [card.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [card.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],

        [stack.topAnchor constraintEqualToAnchor:card.topAnchor constant:20],
        [stack.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:16],
        [stack.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-16],
        [stack.bottomAnchor constraintEqualToAnchor:card.bottomAnchor constant:-20],

        [self.phoneField.heightAnchor constraintEqualToConstant:46],
        [self.passwordField.heightAnchor constraintEqualToConstant:46],
        [self.confirmPasswordField.heightAnchor constraintEqualToConstant:46],
        [registerButton.heightAnchor constraintEqualToConstant:46]
    ]];
}

- (UITextField *)textFieldWithPlaceholder:(NSString *)placeholder {
    UITextField *field = [[UITextField alloc] init];
    field.translatesAutoresizingMaskIntoConstraints = NO;
    field.placeholder = placeholder;
    field.borderStyle = UITextBorderStyleRoundedRect;
    field.clearButtonMode = UITextFieldViewModeWhileEditing;
    return field;
}

- (void)registerTapped {
    NSString *phone = self.phoneField.text ?: @"";
    NSString *password = self.passwordField.text ?: @"";
    NSString *confirm = self.confirmPasswordField.text ?: @"";

    if (![FormValidator isValidPhone11:phone]) {
        [ToastUtils showToastInView:self.view text:@"手机号必须为11位数字"]; return;
    }
    if (![FormValidator isValidPassword:password]) {
        [ToastUtils showToastInView:self.view text:@"密码长度需为6-16位"]; return;
    }
    if (![password isEqualToString:confirm]) {
        [ToastUtils showToastInView:self.view text:@"两次输入的密码不一致"]; return;
    }

    [ToastUtils showLoadingInView:self.view text:@"注册中..."];
    __weak typeof(self) weakSelf = self;
    [[HTTPClient sharedClient] registerWithPhone:phone password:password success:^(UserModel *user) {
        __strong typeof(weakSelf) self = weakSelf;
        [ToastUtils hideLoadingInView:self.view];
        [ToastUtils showToastInView:self.view text:@"注册成功，请登录"];
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(NSError *error, NSString *message, NSInteger code) {
        __strong typeof(weakSelf) self = weakSelf;
        [ToastUtils hideLoadingInView:self.view];
        [ToastUtils showToastInView:self.view text:message ?: @"注册失败"];
    }];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField != self.phoneField) {
        return YES;
    }
    NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (newText.length > 11) {
        return NO;
    }
    NSCharacterSet *invalid = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    return [string rangeOfCharacterFromSet:invalid].location == NSNotFound;
}

@end
