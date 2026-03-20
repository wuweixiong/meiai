// BEGINNER GUIDE:
// File: XDJLoginResponse.h
// Role: Data model: describes app data structure used across layers.
// Reading tip: Read declarations in .h first, then implementation flow in .m.

// XindongrijiApp XDJLoginResponse.h
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XDJLoginResponse : NSObject

@property (nonatomic, copy) NSString *accessToken;
@property (nonatomic, copy) NSString *tokenType;
@property (nonatomic, assign) long long expiresIn;

@end

NS_ASSUME_NONNULL_END
