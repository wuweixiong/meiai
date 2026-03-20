// BEGINNER GUIDE:
// File: XDJAPIClient.m
// Role: Network layer: wraps HTTP calls and translates API requests/responses.
// Reading tip: Read declarations in .h first, then implementation flow in .m.

// XindongrijiApp XDJAPIClient.m
#import "XDJAPIClient.h"
#import <AFNetworking/AFNetworking.h>
#import "Utils/XDJAppConfig.h"
#import "Utils/XDJSessionManager.h"

@interface XDJAPIClient ()

@property (nonatomic, strong) AFHTTPSessionManager *manager;

@end

@implementation XDJAPIClient

+ (instancetype)sharedClient {
    static XDJAPIClient *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[XDJAPIClient alloc] initPrivate];
    });
    return instance;
}

- (instancetype)initPrivate {
    self = [super init];
    if (self) {
        _manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:[XDJAppConfig baseURLString]]];
        _manager.requestSerializer = [AFJSONRequestSerializer serializer];
        _manager.responseSerializer = [AFJSONResponseSerializer serializer];
        _manager.completionQueue = dispatch_get_main_queue();
        [_manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    }
    return self;
}

- (instancetype)init {
    [NSException raise:@"XindongrijiAppSingleton" format:@"Use +[XDJAPIClient sharedClient]."];
    return nil;
}

- (void)refreshAuthHeader {
    NSString *token = [XDJSessionManager sharedManager].accessToken;
    if (token.length > 0) {
        [self.manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", token] forHTTPHeaderField:@"Authorization"];
    } else {
        [self.manager.requestSerializer setValue:nil forHTTPHeaderField:@"Authorization"];
    }
}

- (void)GET:(NSString *)path parameters:(NSDictionary *)parameters success:(XDJAPISuccessBlock)success failure:(XDJAPIFailureBlock)failure {
    [self refreshAuthHeader];
    [self.manager GET:path parameters:parameters headers:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        [self handleResponse:responseObject success:success failure:failure];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self handleError:error failure:failure];
    }];
}

- (void)POST:(NSString *)path parameters:(NSDictionary *)parameters success:(XDJAPISuccessBlock)success failure:(XDJAPIFailureBlock)failure {
    [self refreshAuthHeader];
    [self.manager POST:path parameters:parameters headers:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        [self handleResponse:responseObject success:success failure:failure];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self handleError:error failure:failure];
    }];
}

- (void)PUT:(NSString *)path parameters:(NSDictionary *)parameters success:(XDJAPISuccessBlock)success failure:(XDJAPIFailureBlock)failure {
    [self refreshAuthHeader];
    [self.manager PUT:path parameters:parameters headers:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        [self handleResponse:responseObject success:success failure:failure];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self handleError:error failure:failure];
    }];
}

- (void)DELETE:(NSString *)path parameters:(NSDictionary *)parameters success:(XDJAPISuccessBlock)success failure:(XDJAPIFailureBlock)failure {
    [self refreshAuthHeader];
    [self.manager DELETE:path parameters:parameters headers:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        [self handleResponse:responseObject success:success failure:failure];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self handleError:error failure:failure];
    }];
}

- (void)handleResponse:(id)responseObject success:(XDJAPISuccessBlock)success failure:(XDJAPIFailureBlock)failure {
    if (![responseObject isKindOfClass:[NSDictionary class]]) {
        NSError *error = [NSError errorWithDomain:@"XindongrijiApp.Network" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"响应格式错误"}];
        failure(error, @"响应格式错误");
        return;
    }

    NSDictionary *json = (NSDictionary *)responseObject;
    NSInteger code = [json[@"code"] integerValue];
    NSString *message = json[@"message"] ?: @"";
    if (code == 0) {
        success(json[@"data"]);
    } else {
        NSError *error = [NSError errorWithDomain:@"XindongrijiApp.API" code:code userInfo:@{NSLocalizedDescriptionKey: message}];
        failure(error, message);
    }
}

- (void)handleError:(NSError *)error failure:(XDJAPIFailureBlock)failure {
    NSString *message = error.localizedDescription ?: @"网络异常";
    failure(error, message);
}

@end
