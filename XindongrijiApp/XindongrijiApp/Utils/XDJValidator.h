// BEGINNER GUIDE:
// File: XDJValidator.h
// Role: Shared helper: reusable utilities used by multiple modules.
// Reading tip: Read declarations in .h first, then implementation flow in .m.

// XindongrijiApp XDJValidator.h
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XDJValidator : NSObject

+ (BOOL)isValidPhone:(NSString *)phone;
+ (BOOL)isValidPassword:(NSString *)password;
+ (BOOL)isValidDiaryTitle:(NSString *)title;
+ (BOOL)isValidDiaryContent:(NSString *)content;

@end

NS_ASSUME_NONNULL_END
