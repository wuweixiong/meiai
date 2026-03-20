// BEGINNER GUIDE:
// File: HTTPClient.m
// Role: Network layer: wraps HTTP calls and translates API requests/responses.
// Reading tip: Read declarations in .h first, then implementation flow in .m.

// XindongrijiApp HTTPClient.m
#import "HTTPClient.h"
#import <AFNetworking/AFNetworking.h>
#import <MJExtension/MJExtension.h>
#import "Utils/TokenManager.h"

static NSString * const kXDJBaseURL = @"http://127.0.0.1:8080/api/v1";
static NSString * const kXDJHTTPDomain = @"com.xindongriji.XindongrijiApp.http";

@interface HTTPClient ()

@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;

@end

@implementation HTTPClient

+ (instancetype)sharedClient {
    static HTTPClient *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[HTTPClient alloc] initPrivate];
    });
    return instance;
}

- (instancetype)initPrivate {
    self = [super init];
    if (self) {
        NSURL *baseURL = [NSURL URLWithString:kXDJBaseURL];
        _sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
        _sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
        _sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
        _sessionManager.requestSerializer.timeoutInterval = 15.0;
        [_sessionManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        _sessionManager.completionQueue = dispatch_get_main_queue();
        [AFNetworkReachabilityManager.sharedManager startMonitoring];
    }
    return self;
}

- (instancetype)init {
    [NSException raise:@"XindongrijiAppHTTPClientSingleton" format:@"Use +[HTTPClient sharedClient]."];
    return nil;
}

- (void)updateAuthHeader {
    NSString *auth = [[TokenManager sharedManager] authorizationHeader];
    if (auth.length > 0) {
        [self.sessionManager.requestSerializer setValue:auth forHTTPHeaderField:@"Authorization"];
    } else {
        [self.sessionManager.requestSerializer setValue:nil forHTTPHeaderField:@"Authorization"];
    }
}

- (void)GET:(NSString *)path parameters:(NSDictionary *)parameters success:(HTTPClientSuccessBlock)success failure:(HTTPClientFailureBlock)failure {
    [self updateAuthHeader];
    [self.sessionManager GET:path parameters:parameters headers:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        [self handleResponse:responseObject success:success failure:failure];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self handleError:error failure:failure];
    }];
}

- (void)POST:(NSString *)path parameters:(NSDictionary *)parameters success:(HTTPClientSuccessBlock)success failure:(HTTPClientFailureBlock)failure {
    [self updateAuthHeader];
    [self.sessionManager POST:path parameters:parameters headers:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        [self handleResponse:responseObject success:success failure:failure];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self handleError:error failure:failure];
    }];
}

- (void)PUT:(NSString *)path parameters:(NSDictionary *)parameters success:(HTTPClientSuccessBlock)success failure:(HTTPClientFailureBlock)failure {
    [self updateAuthHeader];
    [self.sessionManager PUT:path parameters:parameters headers:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        [self handleResponse:responseObject success:success failure:failure];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self handleError:error failure:failure];
    }];
}

- (void)DELETE:(NSString *)path parameters:(NSDictionary *)parameters success:(HTTPClientSuccessBlock)success failure:(HTTPClientFailureBlock)failure {
    [self updateAuthHeader];
    [self.sessionManager DELETE:path parameters:parameters headers:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        [self handleResponse:responseObject success:success failure:failure];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self handleError:error failure:failure];
    }];
}

- (void)handleResponse:(id)responseObject success:(HTTPClientSuccessBlock)success failure:(HTTPClientFailureBlock)failure {
    if (![responseObject isKindOfClass:[NSDictionary class]]) {
        NSError *error = [NSError errorWithDomain:kXDJHTTPDomain code:-1 userInfo:@{NSLocalizedDescriptionKey: @"响应数据格式错误"}];
        failure(error, @"响应数据格式错误", -1);
        return;
    }

    NSDictionary *json = (NSDictionary *)responseObject;
    NSInteger code = [json[@"code"] integerValue];
    NSString *message = json[@"message"] ?: @"";
    if (code == 0) {
        success(json[@"data"]);
    } else {
        NSError *error = [NSError errorWithDomain:kXDJHTTPDomain code:code userInfo:@{NSLocalizedDescriptionKey: message.length > 0 ? message : @"请求失败"}];
        failure(error, message.length > 0 ? message : @"请求失败", code);
    }
}

- (void)handleError:(NSError *)error failure:(HTTPClientFailureBlock)failure {
    NSString *message = @"网络异常，请稍后重试";
    if (error.code == NSURLErrorNotConnectedToInternet || error.code == NSURLErrorNetworkConnectionLost) {
        message = @"网络不可用，已切换离线模式";
    } else if (error.code == NSURLErrorTimedOut) {
        message = @"请求超时，请检查网络后重试";
    }
    failure(error, message, error.code);
}

#pragma mark - API

- (void)loginWithPhone:(NSString *)phone password:(NSString *)password success:(HTTPClientTokenSuccessBlock)success failure:(HTTPClientFailureBlock)failure {
    NSDictionary *params = @{@"phone": phone ?: @"", @"password": password ?: @""};
    [self POST:@"/auth/login" parameters:params success:^(id data) {
        NSString *token = [data isKindOfClass:[NSDictionary class]] ? data[@"accessToken"] : nil;
        NSTimeInterval expiresIn = [data[@"expiresIn"] doubleValue];
        if (token.length == 0) {
            NSError *error = [NSError errorWithDomain:kXDJHTTPDomain code:-2 userInfo:@{NSLocalizedDescriptionKey: @"登录响应缺少 token"}];
            failure(error, @"登录响应缺少 token", -2);
            return;
        }
        success(token, expiresIn);
    } failure:failure];
}

- (void)registerWithPhone:(NSString *)phone password:(NSString *)password success:(HTTPClientUserSuccessBlock)success failure:(HTTPClientFailureBlock)failure {
    NSDictionary *params = @{@"phone": phone ?: @"", @"password": password ?: @""};
    [self POST:@"/auth/register" parameters:params success:^(id data) {
        UserModel *user = [UserModel mj_objectWithKeyValues:data];
        success(user);
    } failure:failure];
}

- (void)fetchCurrentUserWithSuccess:(HTTPClientUserSuccessBlock)success failure:(HTTPClientFailureBlock)failure {
    [self GET:@"/users/me" parameters:nil success:^(id data) {
        UserModel *user = [UserModel mj_objectWithKeyValues:data];
        success(user);
    } failure:failure];
}

- (void)updateUserPhone:(NSString *)phone success:(HTTPClientUserSuccessBlock)success failure:(HTTPClientFailureBlock)failure {
    NSDictionary *params = @{@"phone": phone ?: @""};
    [self PUT:@"/users/me" parameters:params success:^(id data) {
        UserModel *user = [UserModel mj_objectWithKeyValues:data];
        success(user);
    } failure:failure];
}

- (void)changePasswordWithOldPassword:(NSString *)oldPassword newPassword:(NSString *)newPassword success:(HTTPClientVoidSuccessBlock)success failure:(HTTPClientFailureBlock)failure {
    NSDictionary *params = @{@"oldPassword": oldPassword ?: @"", @"newPassword": newPassword ?: @""};
    [self PUT:@"/users/me/password" parameters:params success:^(id data) {
        success();
    } failure:failure];
}

- (void)fetchDiariesWithPage:(NSInteger)page size:(NSInteger)size tagId:(NSNumber *)tagId success:(HTTPClientDiaryListSuccessBlock)success failure:(HTTPClientFailureBlock)failure {
    NSMutableDictionary *params = [@{@"page": @(page), @"size": @(size)} mutableCopy];
    if (tagId) {
        params[@"tagId"] = tagId;
    }

    [self GET:@"/diaries" parameters:params success:^(id data) {
        NSArray *itemsJSON = [data isKindOfClass:[NSDictionary class]] ? data[@"items"] : @[];
        NSArray<DiaryModel *> *items = [DiaryModel mj_objectArrayWithKeyValuesArray:itemsJSON];
        NSInteger total = [data[@"total"] integerValue];
        success(items, total);
    } failure:failure];
}

- (void)createDiaryWithTitle:(NSString *)title content:(NSString *)content date:(NSString *)date tagIds:(NSArray<NSNumber *> *)tagIds success:(HTTPClientDiarySuccessBlock)success failure:(HTTPClientFailureBlock)failure {
    NSDictionary *params = @{
        @"title": title ?: @"",
        @"content": content ?: @"",
        @"date": date ?: @"",
        @"tagIds": tagIds ?: @[]
    };

    [self POST:@"/diaries" parameters:params success:^(id data) {
        DiaryModel *diary = [DiaryModel mj_objectWithKeyValues:data];
        success(diary);
    } failure:failure];
}

- (void)updateDiaryId:(NSInteger)diaryId title:(NSString *)title content:(NSString *)content date:(NSString *)date tagIds:(NSArray<NSNumber *> *)tagIds success:(HTTPClientDiarySuccessBlock)success failure:(HTTPClientFailureBlock)failure {
    NSString *path = [NSString stringWithFormat:@"/diaries/%ld", (long)diaryId];
    NSDictionary *params = @{
        @"title": title ?: @"",
        @"content": content ?: @"",
        @"date": date ?: @"",
        @"tagIds": tagIds ?: @[]
    };

    [self PUT:path parameters:params success:^(id data) {
        DiaryModel *diary = [DiaryModel mj_objectWithKeyValues:data];
        success(diary);
    } failure:failure];
}

- (void)deleteDiaryId:(NSInteger)diaryId success:(HTTPClientVoidSuccessBlock)success failure:(HTTPClientFailureBlock)failure {
    NSString *path = [NSString stringWithFormat:@"/diaries/%ld", (long)diaryId];
    [self DELETE:path parameters:nil success:^(id data) {
        success();
    } failure:failure];
}

- (void)fetchTagsWithSuccess:(HTTPClientTagListSuccessBlock)success failure:(HTTPClientFailureBlock)failure {
    [self GET:@"/tags" parameters:nil success:^(id data) {
        NSArray<TagModel *> *tags = [TagModel mj_objectArrayWithKeyValuesArray:data];
        success(tags ?: @[]);
    } failure:failure];
}

- (void)createTagWithName:(NSString *)name success:(HTTPClientTagSuccessBlock)success failure:(HTTPClientFailureBlock)failure {
    NSDictionary *params = @{@"name": name ?: @""};
    [self POST:@"/tags" parameters:params success:^(id data) {
        TagModel *tag = [TagModel mj_objectWithKeyValues:data];
        success(tag);
    } failure:failure];
}

- (void)updateTagId:(NSInteger)tagId name:(NSString *)name success:(HTTPClientTagSuccessBlock)success failure:(HTTPClientFailureBlock)failure {
    NSString *path = [NSString stringWithFormat:@"/tags/%ld", (long)tagId];
    NSDictionary *params = @{@"name": name ?: @""};
    [self PUT:path parameters:params success:^(id data) {
        TagModel *tag = [TagModel mj_objectWithKeyValues:data];
        success(tag);
    } failure:failure];
}

- (void)deleteTagId:(NSInteger)tagId success:(HTTPClientVoidSuccessBlock)success failure:(HTTPClientFailureBlock)failure {
    NSString *path = [NSString stringWithFormat:@"/tags/%ld", (long)tagId];
    [self DELETE:path parameters:nil success:^(id data) {
        success();
    } failure:failure];
}

@end
