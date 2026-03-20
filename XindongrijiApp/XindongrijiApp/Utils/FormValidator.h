// BEGINNER GUIDE:
// File: FormValidator.h
// Role: Shared helper: reusable utilities used by multiple modules.
// Reading tip: Read declarations in .h first, then implementation flow in .m.

// XindongrijiApp FormValidator.h
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FormValidator : NSObject

+ (BOOL)isValidPhone11:(NSString *)phone;
+ (BOOL)isValidPassword:(NSString *)password;
+ (BOOL)isValidDiaryTitle:(NSString *)title;
+ (BOOL)isValidDiaryContent:(NSString *)content;

@end

NS_ASSUME_NONNULL_END
