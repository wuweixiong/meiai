// BEGINNER GUIDE:
// File: LoginViewController.m
// Role: UI layer: builds screens, handles taps, and calls services.
// Reading tip: Read declarations in .h first, then implementation flow in .m.

// XindongrijiApp LoginViewController.m
#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "Network/HTTPClient.h"
#import "Utils/FormValidator.h"
#import "Utils/ToastUtils.h"
#import "Utils/TokenManager.h"
#import "DB/CoreDataManager.h"
#import "Utils/AppRouter.h"

@interface LoginViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *phoneField;
@property (nonatomic, strong) UITextField *passwordField;
@property (nonatomic, strong) UIButton *loginButton;
@property (nonatomic, strong) UIButton *registerButton;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"心动日记";
    self.view.backgroundColor = [UIColor colorWithRed:1.0 green:0.97 blue:0.98 alpha:1.0];

    [self buildUI];
}

- (void)buildUI {
    UILabel *sloganLabel = [[UILabel alloc] init];
    sloganLabel.translatesAutoresizingMaskIntoConstraints = NO;
    sloganLabel.text = @"记录每一次心动";
    sloganLabel.textAlignment = NSTextAlignmentCenter;
    sloganLabel.font = [UIFont boldSystemFontOfSize:28];
    sloganLabel.textColor = [UIColor colorWithRed:0.94 green:0.32 blue:0.52 alpha:1.0];
    [self.view addSubview:sloganLabel];

    UIView *cardView = [[UIView alloc] init];
    cardView.translatesAutoresizingMaskIntoConstraints = NO;
    cardView.backgroundColor = UIColor.whiteColor;
    cardView.layer.cornerRadius = 16;
    cardView.layer.shadowColor = [UIColor blackColor].CGColor;
    cardView.layer.shadowOpacity = 0.08;
    cardView.layer.shadowOffset = CGSizeMake(0, 8);
    cardView.layer.shadowRadius = 20;
    [self.view addSubview:cardView];

    self.phoneField = [self textFieldWithPlaceholder:@"请输入11位手机号"];
    self.phoneField.keyboardType = UIKeyboardTypeNumberPad;
    self.phoneField.delegate = self;

    self.passwordField = [self textFieldWithPlaceholder:@"请输入密码（6-16位）"];
    self.passwordField.secureTextEntry = YES;

    self.loginButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.loginButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.loginButton setTitle:@"登录" forState:UIControlStateNormal];
    self.loginButton.backgroundColor = [UIColor colorWithRed:0.94 green:0.32 blue:0.52 alpha:1.0];
    [self.loginButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    self.loginButton.layer.cornerRadius = 10;
    self.loginButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    [self.loginButton addTarget:self action:@selector(loginTapped) forControlEvents:UIControlEventTouchUpInside];

    self.registerButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.registerButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.registerButton setTitle:@"没有账号？去注册" forState:UIControlStateNormal];
    [self.registerButton setTitleColor:[UIColor colorWithRed:0.78 green:0.24 blue:0.45 alpha:1.0] forState:UIControlStateNormal];
    [self.registerButton addTarget:self action:@selector(registerTapped) forControlEvents:UIControlEventTouchUpInside];

    UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:@[self.phoneField, self.passwordField, self.loginButton, self.registerButton]];
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 14;
    [cardView addSubview:stack];

    [NSLayoutConstraint activateConstraints:@[
        [sloganLabel.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:38],
        [sloganLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:24],
        [sloganLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-24],

        [cardView.topAnchor constraintEqualToAnchor:sloganLabel.bottomAnchor constant:28],
        [cardView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [cardView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],

        [stack.topAnchor constraintEqualToAnchor:cardView.topAnchor constant:22],
        [stack.leadingAnchor constraintEqualToAnchor:cardView.leadingAnchor constant:16],
        [stack.trailingAnchor constraintEqualToAnchor:cardView.trailingAnchor constant:-16],
        [stack.bottomAnchor constraintEqualToAnchor:cardView.bottomAnchor constant:-20],

        [self.phoneField.heightAnchor constraintEqualToConstant:46],
        [self.passwordField.heightAnchor constraintEqualToConstant:46],
        [self.loginButton.heightAnchor constraintEqualToConstant:46]
    ]];
}

- (UITextField *)textFieldWithPlaceholder:(NSString *)placeholder {
    UITextField *field = [[UITextField alloc] init];
    field.translatesAutoresizingMaskIntoConstraints = NO;
    field.placeholder = placeholder;
    field.borderStyle = UITextBorderStyleRoundedRect;
    field.clearButtonMode = UITextFieldViewModeWhileEditing;
    field.autocapitalizationType = UITextAutocapitalizationTypeNone;
    field.autocorrectionType = UITextAutocorrectionTypeNo;
    return field;
}

- (void)loginTapped {
    NSString *phone = self.phoneField.text ?: @"";
    NSString *password = self.passwordField.text ?: @"";

    if (![FormValidator isValidPhone11:phone]) {
        [ToastUtils showToastInView:self.view text:@"手机号必须为11位数字"]; return;
    }
    if (![FormValidator isValidPassword:password]) {
        [ToastUtils showToastInView:self.view text:@"密码长度需为6-16位"]; return;
    }

    [ToastUtils showLoadingInView:self.view text:@"登录中..."];
    __weak typeof(self) weakSelf = self;
    [[HTTPClient sharedClient] loginWithPhone:phone password:password success:^(NSString *accessToken, NSTimeInterval expiresIn) {
        __strong typeof(weakSelf) self = weakSelf;
        [[TokenManager sharedManager] saveToken:accessToken expiresIn:expiresIn];

        [[HTTPClient sharedClient] fetchCurrentUserWithSuccess:^(UserModel *user) {
            [[CoreDataManager sharedManager] cacheCurrentUser:user];
            [ToastUtils hideLoadingInView:self.view];
            [AppRouter switchToMainAppWithAnimation:YES];
        } failure:^(NSError *error, NSString *message, NSInteger code) {
            [ToastUtils hideLoadingInView:self.view];
            [ToastUtils showToastInView:self.view text:message ?: @"获取用户信息失败"];
        }];
    } failure:^(NSError *error, NSString *message, NSInteger code) {
        __strong typeof(weakSelf) self = weakSelf;
        [ToastUtils hideLoadingInView:self.view];
        [ToastUtils showToastInView:self.view text:message ?: @"登录失败"];
    }];
}

- (void)registerTapped {
    RegisterViewController *registerVC = [[RegisterViewController alloc] init];
    [self.navigationController pushViewController:registerVC animated:YES];
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
