// BEGINNER GUIDE:
// File: XDJAPIClient.h
// Role: Network layer: wraps HTTP calls and translates API requests/responses.
// Reading tip: Read declarations in .h first, then implementation flow in .m.

// XindongrijiApp XDJAPIClient.h
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^XDJAPISuccessBlock)(id _Nullable data);
typedef void(^XDJAPIFailureBlock)(NSError *error, NSString * _Nullable message);

@interface XDJAPIClient : NSObject

+ (instancetype)sharedClient;

- (void)GET:(NSString *)path
 parameters:(nullable NSDictionary *)parameters
    success:(XDJAPISuccessBlock)success
    failure:(XDJAPIFailureBlock)failure;

- (void)POST:(NSString *)path
  parameters:(nullable NSDictionary *)parameters
     success:(XDJAPISuccessBlock)success
     failure:(XDJAPIFailureBlock)failure;

- (void)PUT:(NSString *)path
 parameters:(nullable NSDictionary *)parameters
    success:(XDJAPISuccessBlock)success
    failure:(XDJAPIFailureBlock)failure;

- (void)DELETE:(NSString *)path
    parameters:(nullable NSDictionary *)parameters
       success:(XDJAPISuccessBlock)success
       failure:(XDJAPIFailureBlock)failure;

@end

NS_ASSUME_NONNULL_END
