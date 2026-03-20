// BEGINNER GUIDE:
// File: AppDelegate.m
// Role: App lifecycle entry: handles app startup and global setup.
// Reading tip: Read declarations in .h first, then implementation flow in .m.

// XindongrijiApp AppDelegate.m
#import "AppDelegate.h"
#import "DB/CoreDataManager.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [CoreDataManager sharedManager];
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[CoreDataManager sharedManager] saveContext];
}

@end
