// BEGINNER GUIDE:
// File: MainTabBarController.m
// Role: UI layer: builds screens, handles taps, and calls services.
// Reading tip: Read declarations in .h first, then implementation flow in .m.

// XindongrijiApp MainTabBarController.m
#import "MainTabBarController.h"
#import "Diary/DiaryListViewController.h"
#import "Profile/ProfileViewController.h"

@implementation MainTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];

    DiaryListViewController *diaryVC = [[DiaryListViewController alloc] init];
    UINavigationController *diaryNav = [[UINavigationController alloc] initWithRootViewController:diaryVC];
    diaryNav.tabBarItem.title = @"日记";
    diaryNav.tabBarItem.image = [UIImage systemImageNamed:@"book.closed"];

    ProfileViewController *profileVC = [[ProfileViewController alloc] init];
    UINavigationController *profileNav = [[UINavigationController alloc] initWithRootViewController:profileVC];
    profileNav.tabBarItem.title = @"我的";
    profileNav.tabBarItem.image = [UIImage systemImageNamed:@"person.crop.circle"];

    self.viewControllers = @[diaryNav, profileNav];
    self.tabBar.tintColor = [UIColor colorWithRed:0.98 green:0.36 blue:0.50 alpha:1.0];
}

@end
