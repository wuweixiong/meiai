// BEGINNER GUIDE:
// File: AppRouter.m
// Role: Shared helper: reusable utilities used by multiple modules.
// Reading tip: Read declarations in .h first, then implementation flow in .m.

// XindongrijiApp AppRouter.m
#import "AppRouter.h"
#import <QuartzCore/QuartzCore.h>
#import "ViewController/Auth/LoginViewController.h"
#import "ViewController/MainTabBarController.h"

@implementation AppRouter

+ (UIWindow *)mainWindow {
    for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
        if (![scene isKindOfClass:[UIWindowScene class]]) {
            continue;
        }
        UIWindowScene *windowScene = (UIWindowScene *)scene;
        for (UIWindow *window in windowScene.windows) {
            if (window.isKeyWindow) {
                return window;
            }
        }
        if (windowScene.windows.count > 0) {
            return windowScene.windows.firstObject;
        }
    }
    return UIApplication.sharedApplication.windows.firstObject;
}

+ (void)updateRootViewController:(UIViewController *)rootViewController animated:(BOOL)animated {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window = [self mainWindow];
        if (!window) {
            return;
        }
        window.rootViewController = rootViewController;
        [window makeKeyAndVisible];
        if (animated) {
            CATransition *transition = [CATransition animation];
            transition.type = kCATransitionFade;
            transition.duration = 0.25;
            [window.layer addAnimation:transition forKey:nil];
        }
    });
}

+ (void)switchToLoginWithAnimation:(BOOL)animated {
    LoginViewController *loginVC = [[LoginViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginVC];
    [self updateRootViewController:nav animated:animated];
}

+ (void)switchToMainAppWithAnimation:(BOOL)animated {
    MainTabBarController *mainTabBar = [[MainTabBarController alloc] init];
    [self updateRootViewController:mainTabBar animated:animated];
}

@end
