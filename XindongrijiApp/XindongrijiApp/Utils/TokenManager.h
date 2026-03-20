// BEGINNER GUIDE:
// File: TokenManager.h
// Role: Shared helper: reusable utilities used by multiple modules.
// Reading tip: Read declarations in .h first, then implementation flow in .m.

// XindongrijiApp TokenManager.h
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TokenManager : NSObject

+ (instancetype)sharedManager;

- (void)saveToken:(NSString *)token expiresIn:(NSTimeInterval)expiresIn;
- (nullable NSString *)token;
- (BOOL)hasValidToken;
- (nullable NSString *)authorizationHeader;
- (void)clearToken;

@end

NS_ASSUME_NONNULL_END
