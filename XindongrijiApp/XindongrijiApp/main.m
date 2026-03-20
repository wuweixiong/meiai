// BEGINNER GUIDE:
// File: main.m
// Role: Process entry point: starts iOS application runtime.
// Reading tip: Read declarations in .h first, then implementation flow in .m.

// XindongrijiApp main.m
#import <UIKit/UIKit.h>
#import "AppDelegate.h"

int main(int argc, char * argv[]) {
    NSString *appDelegateClassName;
    @autoreleasepool {
        appDelegateClassName = NSStringFromClass([AppDelegate class]);
    }
    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}
