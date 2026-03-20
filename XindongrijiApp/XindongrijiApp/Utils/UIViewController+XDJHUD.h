// BEGINNER GUIDE:
// File: UIViewController+XDJHUD.h
// Role: Shared helper: reusable utilities used by multiple modules.
// Reading tip: Read declarations in .h first, then implementation flow in .m.

// XindongrijiApp UIViewController+XDJHUD.h
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (XDJHUD)

- (void)xdj_showLoading:(NSString *)message;
- (void)xdj_hideLoading;
- (void)xdj_showToast:(NSString *)message;

@end

NS_ASSUME_NONNULL_END
