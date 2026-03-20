// BEGINNER GUIDE:
// File: ProfileViewController.m
// Role: UI layer: builds screens, handles taps, and calls services.
// Reading tip: Read declarations in .h first, then implementation flow in .m.

// XindongrijiApp ProfileViewController.m
#import "ProfileViewController.h"
#import "Network/HTTPClient.h"
#import "DB/CoreDataManager.h"
#import "Utils/FormValidator.h"
#import "Utils/TokenManager.h"
#import "Utils/ToastUtils.h"
#import "Utils/AppRouter.h"

@interface ProfileViewController ()

@property (nonatomic, strong) UILabel *userIdLabel;
@property (nonatomic, strong) UILabel *phoneLabel;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"个人中心";
    self.view.backgroundColor = [UIColor colorWithRed:0.98 green:0.98 blue:0.99 alpha:1.0];

    [self buildUI];
    [self loadUserFromCache];
    [self requestUserFromServer];
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

    UILabel *avatar = [[UILabel alloc] init];
    avatar.translatesAutoresizingMaskIntoConstraints = NO;
    avatar.text = @"❤";
    avatar.textAlignment = NSTextAlignmentCenter;
    avatar.font = [UIFont systemFontOfSize:42];

    self.userIdLabel = [[UILabel alloc] init];
    self.userIdLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.userIdLabel.textColor = [UIColor colorWithRed:0.26 green:0.28 blue:0.34 alpha:1.0];

    self.phoneLabel = [[UILabel alloc] init];
    self.phoneLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.phoneLabel.textColor = [UIColor colorWithRed:0.26 green:0.28 blue:0.34 alpha:1.0];

    UIButton *refreshButton = [self actionButtonWithTitle:@"刷新用户信息" selector:@selector(requestUserFromServer) color:[UIColor colorWithRed:0.24 green:0.54 blue:0.96 alpha:1.0]];
    UIButton *changePasswordButton = [self actionButtonWithTitle:@"修改密码" selector:@selector(changePasswordTapped) color:[UIColor colorWithRed:0.95 green:0.52 blue:0.18 alpha:1.0]];
    UIButton *logoutButton = [self actionButtonWithTitle:@"退出登录" selector:@selector(logoutTapped) color:[UIColor colorWithRed:0.89 green:0.23 blue:0.29 alpha:1.0]];

    UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:@[avatar, self.userIdLabel, self.phoneLabel, refreshButton, changePasswordButton, logoutButton]];
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 14;
    [card addSubview:stack];

    [NSLayoutConstraint activateConstraints:@[
        [card.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:20],
        [card.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [card.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],

        [stack.topAnchor constraintEqualToAnchor:card.topAnchor constant:20],
        [stack.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:16],
        [stack.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-16],
        [stack.bottomAnchor constraintEqualToAnchor:card.bottomAnchor constant:-20],

        [refreshButton.heightAnchor constraintEqualToConstant:44],
        [changePasswordButton.heightAnchor constraintEqualToConstant:44],
        [logoutButton.heightAnchor constraintEqualToConstant:44]
    ]];
}

- (UIButton *)actionButtonWithTitle:(NSString *)title selector:(SEL)selector color:(UIColor *)color {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    button.backgroundColor = color;
    button.layer.cornerRadius = 10;
    button.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)loadUserFromCache {
    UserModel *cached = [[CoreDataManager sharedManager] cachedCurrentUser];
    [self updateUserInfo:cached];
}

- (void)requestUserFromServer {
    __weak typeof(self) weakSelf = self;
    [[HTTPClient sharedClient] fetchCurrentUserWithSuccess:^(UserModel *user) {
        __strong typeof(weakSelf) self = weakSelf;
        [[CoreDataManager sharedManager] cacheCurrentUser:user];
        [self updateUserInfo:user];
    } failure:^(NSError *error, NSString *message, NSInteger code) {
        __strong typeof(weakSelf) self = weakSelf;
        [ToastUtils showToastInView:self.view text:message ?: @"获取用户失败"];
    }];
}

- (void)updateUserInfo:(nullable UserModel *)user {
    self.userIdLabel.text = [NSString stringWithFormat:@"用户ID：%@", user ? @(user.userId) : @"--"];
    self.phoneLabel.text = [NSString stringWithFormat:@"手机号：%@", user.phone.length > 0 ? user.phone : @"--"];
}

- (void)changePasswordTapped {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"修改密码" message:@"当前后端默认未开放该接口，已预留调用位" preferredStyle:UIAlertControllerStyleAlert];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"旧密码";
        textField.secureTextEntry = YES;
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"新密码（6-16位）";
        textField.secureTextEntry = YES;
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"确认新密码";
        textField.secureTextEntry = YES;
    }];

    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *oldPassword = alert.textFields[0].text ?: @"";
        NSString *newPassword = alert.textFields[1].text ?: @"";
        NSString *confirmPassword = alert.textFields[2].text ?: @"";

        if (![FormValidator isValidPassword:oldPassword] || ![FormValidator isValidPassword:newPassword]) {
            [ToastUtils showToastInView:self.view text:@"密码长度需为6-16位"];
            return;
        }
        if (![newPassword isEqualToString:confirmPassword]) {
            [ToastUtils showToastInView:self.view text:@"两次输入的新密码不一致"];
            return;
        }

        [ToastUtils showLoadingInView:self.view text:@"提交中..."];
        [[HTTPClient sharedClient] changePasswordWithOldPassword:oldPassword newPassword:newPassword success:^{
            [ToastUtils hideLoadingInView:self.view];
            [ToastUtils showToastInView:self.view text:@"密码修改成功"];
        } failure:^(NSError *error, NSString *message, NSInteger code) {
            [ToastUtils hideLoadingInView:self.view];
            if (code == 404 || [message containsString:@"not found"] || [message containsString:@"404"]) {
                [ToastUtils showToastInView:self.view text:@"后端暂未提供修改密码接口，请先在服务端补充"];
                return;
            }
            [ToastUtils showToastInView:self.view text:message ?: @"修改失败"];
        }];
    }]];

    [self presentViewController:alert animated:YES completion:nil];
}

- (void)logoutTapped {
    [[TokenManager sharedManager] clearToken];
    [[CoreDataManager sharedManager] clearAllCache];
    [AppRouter switchToLoginWithAnimation:YES];
}

@end
