// BEGINNER GUIDE:
// File: XDJAppConfig.m
// Role: Shared helper: reusable utilities used by multiple modules.
// Reading tip: Read declarations in .h first, then implementation flow in .m.

// XindongrijiApp XDJAppConfig.m
#import "XDJAppConfig.h"

@implementation XDJAppConfig

+ (NSString *)baseURLString {
    // Update this address to your xindongriji-backend server endpoint.
    return @"http://127.0.0.1:8080/api/v1";
}

@end
