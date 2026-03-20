// BEGINNER GUIDE:
// File: XDJSessionManager.h
// Role: Shared helper: reusable utilities used by multiple modules.
// Reading tip: Read declarations in .h first, then implementation flow in .m.

// XindongrijiApp XDJSessionManager.h
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XDJSessionManager : NSObject

@property (nonatomic, copy, nullable, readonly) NSString *accessToken;
@property (nonatomic, copy, nullable, readonly) NSString *phone;
@property (nonatomic, assign, readonly) BOOL hasLoginSession;

+ (instancetype)sharedManager;
- (void)updateToken:(nullable NSString *)token phone:(nullable NSString *)phone;
- (void)clearSession;

@end

NS_ASSUME_NONNULL_END
