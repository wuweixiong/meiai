// BEGINNER GUIDE:
// File: ToastUtils.h
// Role: Shared helper: reusable utilities used by multiple modules.
// Reading tip: Read declarations in .h first, then implementation flow in .m.

// XindongrijiApp ToastUtils.h
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ToastUtils : NSObject

+ (void)showLoadingInView:(UIView *)view text:(nullable NSString *)text;
+ (void)hideLoadingInView:(UIView *)view;
+ (void)showToastInView:(UIView *)view text:(NSString *)text;

@end

NS_ASSUME_NONNULL_END
