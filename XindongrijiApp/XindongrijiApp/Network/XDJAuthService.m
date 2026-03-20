// BEGINNER GUIDE:
// File: XDJAuthService.m
// Role: Network layer: wraps HTTP calls and translates API requests/responses.
// Reading tip: Read declarations in .h first, then implementation flow in .m.

// XindongrijiApp XDJAuthService.m
#import "XDJAuthService.h"
#import "XDJAPIClient.h"
#import <MJExtension/MJExtension.h>

@implementation XDJAuthService

- (void)registerWithPhone:(NSString *)phone password:(NSString *)password success:(XDJUserSuccessBlock)success failure:(XDJFailureBlock)failure {
    NSDictionary *params = @{@"phone": phone ?: @"", @"password": password ?: @""};
    [[XDJAPIClient sharedClient] POST:@"/auth/register" parameters:params success:^(id data) {
        XDJUser *user = [XDJUser mj_objectWithKeyValues:data];
        success(user);
    } failure:failure];
}

- (void)loginWithPhone:(NSString *)phone password:(NSString *)password success:(XDJLoginSuccessBlock)success failure:(XDJFailureBlock)failure {
    NSDictionary *params = @{@"phone": phone ?: @"", @"password": password ?: @""};
    [[XDJAPIClient sharedClient] POST:@"/auth/login" parameters:params success:^(id data) {
        XDJLoginResponse *response = [XDJLoginResponse mj_objectWithKeyValues:data];
        success(response);
    } failure:failure];
}

- (void)fetchCurrentUserWithSuccess:(XDJUserSuccessBlock)success failure:(XDJFailureBlock)failure {
    [[XDJAPIClient sharedClient] GET:@"/users/me" parameters:nil success:^(id data) {
        XDJUser *user = [XDJUser mj_objectWithKeyValues:data];
        success(user);
    } failure:failure];
}

@end
