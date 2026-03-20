// BEGINNER GUIDE:
// File: UIViewController+XDJHUD.m
// Role: Shared helper: reusable utilities used by multiple modules.
// Reading tip: Read declarations in .h first, then implementation flow in .m.

// XindongrijiApp UIViewController+XDJHUD.m
#import "UIViewController+XDJHUD.h"
#import <MBProgressHUD/MBProgressHUD.h>

@implementation UIViewController (XDJHUD)

- (void)xdj_showLoading:(NSString *)message {
    [MBProgressHUD hideHUDForView:self.view animated:NO];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = message.length > 0 ? message : @"加载中...";
}

- (void)xdj_hideLoading {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)xdj_showToast:(NSString *)message {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = message;
    hud.removeFromSuperViewOnHide = YES;
    [hud hideAnimated:YES afterDelay:1.5];
}

@end
