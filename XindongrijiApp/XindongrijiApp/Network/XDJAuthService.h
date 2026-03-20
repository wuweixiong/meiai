// BEGINNER GUIDE:
// File: XDJAuthService.h
// Role: Network layer: wraps HTTP calls and translates API requests/responses.
// Reading tip: Read declarations in .h first, then implementation flow in .m.

// XindongrijiApp XDJAuthService.h
#import <Foundation/Foundation.h>
#import "Model/XDJLoginResponse.h"
#import "Model/XDJUser.h"
#import "XDJNetworkDefines.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^XDJLoginSuccessBlock)(XDJLoginResponse *response);
typedef void(^XDJUserSuccessBlock)(XDJUser *user);

@interface XDJAuthService : NSObject

- (void)registerWithPhone:(NSString *)phone
                 password:(NSString *)password
                  success:(XDJUserSuccessBlock)success
                  failure:(XDJFailureBlock)failure;

- (void)loginWithPhone:(NSString *)phone
              password:(NSString *)password
               success:(XDJLoginSuccessBlock)success
               failure:(XDJFailureBlock)failure;

- (void)fetchCurrentUserWithSuccess:(XDJUserSuccessBlock)success
                            failure:(XDJFailureBlock)failure;

@end

NS_ASSUME_NONNULL_END
