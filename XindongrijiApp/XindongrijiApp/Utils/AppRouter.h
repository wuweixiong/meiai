// BEGINNER GUIDE:
// File: AppRouter.h
// Role: Shared helper: reusable utilities used by multiple modules.
// Reading tip: Read declarations in .h first, then implementation flow in .m.

// XindongrijiApp AppRouter.h
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AppRouter : NSObject

+ (void)switchToLoginWithAnimation:(BOOL)animated;
+ (void)switchToMainAppWithAnimation:(BOOL)animated;
+ (UIWindow *)mainWindow;

@end

NS_ASSUME_NONNULL_END
