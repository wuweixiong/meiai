// BEGINNER GUIDE:
// File: FormValidator.m
// Role: Shared helper: reusable utilities used by multiple modules.
// Reading tip: Read declarations in .h first, then implementation flow in .m.

// XindongrijiApp FormValidator.m
#import "FormValidator.h"

@implementation FormValidator

+ (BOOL)isValidPhone11:(NSString *)phone {
    if (phone.length != 11) {
        return NO;
    }
    NSCharacterSet *notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    return [phone rangeOfCharacterFromSet:notDigits].location == NSNotFound;
}

+ (BOOL)isValidPassword:(NSString *)password {
    return password.length >= 6 && password.length <= 16;
}

+ (BOOL)isValidDiaryTitle:(NSString *)title {
    return title.length > 0 && title.length <= 100;
}

+ (BOOL)isValidDiaryContent:(NSString *)content {
    return content.length > 0;
}

@end
