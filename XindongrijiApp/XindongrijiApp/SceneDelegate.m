// BEGINNER GUIDE:
// File: SceneDelegate.m
// Role: Scene lifecycle entry: manages window/root screen for each scene.
// Reading tip: Read declarations in .h first, then implementation flow in .m.

// XindongrijiApp SceneDelegate.m
#import "SceneDelegate.h"
#import "Utils/TokenManager.h"
#import "ViewController/Auth/LoginViewController.h"
#import "ViewController/MainTabBarController.h"

@implementation SceneDelegate

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    if (![scene isKindOfClass:[UIWindowScene class]]) {
        return;
    }

    UIWindowScene *windowScene = (UIWindowScene *)scene;
    self.window = [[UIWindow alloc] initWithWindowScene:windowScene];

    UIViewController *rootVC = nil;
    if ([[TokenManager sharedManager] hasValidToken]) {
        rootVC = [[MainTabBarController alloc] init];
    } else {
        LoginViewController *loginVC = [[LoginViewController alloc] init];
        rootVC = [[UINavigationController alloc] initWithRootViewController:loginVC];
    }

    self.window.rootViewController = rootVC;
    [self.window makeKeyAndVisible];
}

@end
