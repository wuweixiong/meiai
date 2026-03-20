// BEGINNER GUIDE:
// File: XDJValidator.m
// Role: Shared helper: reusable utilities used by multiple modules.
// Reading tip: Read declarations in .h first, then implementation flow in .m.

// XindongrijiApp XDJValidator.m
#import "XDJValidator.h"

@implementation XDJValidator

+ (BOOL)isValidPhone:(NSString *)phone {
    return phone.length >= 6 && phone.length <= 20;
}

+ (BOOL)isValidPassword:(NSString *)password {
    return password.length >= 6 && password.length <= 50;
}

+ (BOOL)isValidDiaryTitle:(NSString *)title {
    return title.length > 0 && title.length <= 100;
}

+ (BOOL)isValidDiaryContent:(NSString *)content {
    return content.length > 0;
}

@end
