// BEGINNER GUIDE:
// File: ToastUtils.m
// Role: Shared helper: reusable utilities used by multiple modules.
// Reading tip: Read declarations in .h first, then implementation flow in .m.

// XindongrijiApp ToastUtils.m
#import "ToastUtils.h"
#import <MBProgressHUD/MBProgressHUD.h>

@implementation ToastUtils

+ (void)showLoadingInView:(UIView *)view text:(NSString *)text {
    [MBProgressHUD hideHUDForView:view animated:NO];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.label.text = text.length > 0 ? text : @"加载中...";
}

+ (void)hideLoadingInView:(UIView *)view {
    [MBProgressHUD hideHUDForView:view animated:YES];
}

+ (void)showToastInView:(UIView *)view text:(NSString *)text {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = text;
    hud.margin = 12;
    hud.removeFromSuperViewOnHide = YES;
    [hud hideAnimated:YES afterDelay:1.4];
}

@end
