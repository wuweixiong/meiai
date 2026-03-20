// BEGINNER GUIDE:
// File: HTTPClient.h
// Role: Network layer: wraps HTTP calls and translates API requests/responses.
// Reading tip: Read declarations in .h first, then implementation flow in .m.

// XindongrijiApp HTTPClient.h
#import <Foundation/Foundation.h>
#import "Model/UserModel.h"
#import "Model/DiaryModel.h"
#import "Model/TagModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^HTTPClientSuccessBlock)(id _Nullable data);
typedef void(^HTTPClientFailureBlock)(NSError *error, NSString *message, NSInteger code);

typedef void(^HTTPClientTokenSuccessBlock)(NSString *accessToken, NSTimeInterval expiresIn);
typedef void(^HTTPClientUserSuccessBlock)(UserModel *user);
typedef void(^HTTPClientDiaryListSuccessBlock)(NSArray<DiaryModel *> *items, NSInteger total);
typedef void(^HTTPClientDiarySuccessBlock)(DiaryModel *diary);
typedef void(^HTTPClientTagListSuccessBlock)(NSArray<TagModel *> *items);
typedef void(^HTTPClientTagSuccessBlock)(TagModel *tag);
typedef void(^HTTPClientVoidSuccessBlock)(void);

@interface HTTPClient : NSObject

+ (instancetype)sharedClient;

// Generic methods
- (void)GET:(NSString *)path
 parameters:(nullable NSDictionary *)parameters
    success:(HTTPClientSuccessBlock)success
    failure:(HTTPClientFailureBlock)failure;

- (void)POST:(NSString *)path
  parameters:(nullable NSDictionary *)parameters
     success:(HTTPClientSuccessBlock)success
     failure:(HTTPClientFailureBlock)failure;

- (void)PUT:(NSString *)path
 parameters:(nullable NSDictionary *)parameters
    success:(HTTPClientSuccessBlock)success
    failure:(HTTPClientFailureBlock)failure;

- (void)DELETE:(NSString *)path
    parameters:(nullable NSDictionary *)parameters
       success:(HTTPClientSuccessBlock)success
       failure:(HTTPClientFailureBlock)failure;

// API methods
- (void)loginWithPhone:(NSString *)phone
              password:(NSString *)password
               success:(HTTPClientTokenSuccessBlock)success
               failure:(HTTPClientFailureBlock)failure;

- (void)registerWithPhone:(NSString *)phone
                 password:(NSString *)password
                  success:(HTTPClientUserSuccessBlock)success
                  failure:(HTTPClientFailureBlock)failure;

- (void)fetchCurrentUserWithSuccess:(HTTPClientUserSuccessBlock)success
                            failure:(HTTPClientFailureBlock)failure;

- (void)updateUserPhone:(NSString *)phone
                success:(HTTPClientUserSuccessBlock)success
                failure:(HTTPClientFailureBlock)failure;

- (void)changePasswordWithOldPassword:(NSString *)oldPassword
                           newPassword:(NSString *)newPassword
                               success:(HTTPClientVoidSuccessBlock)success
                               failure:(HTTPClientFailureBlock)failure;

- (void)fetchDiariesWithPage:(NSInteger)page
                        size:(NSInteger)size
                       tagId:(nullable NSNumber *)tagId
                     success:(HTTPClientDiaryListSuccessBlock)success
                     failure:(HTTPClientFailureBlock)failure;

- (void)createDiaryWithTitle:(NSString *)title
                     content:(NSString *)content
                        date:(NSString *)date
                      tagIds:(NSArray<NSNumber *> *)tagIds
                     success:(HTTPClientDiarySuccessBlock)success
                     failure:(HTTPClientFailureBlock)failure;

- (void)updateDiaryId:(NSInteger)diaryId
                title:(NSString *)title
              content:(NSString *)content
                 date:(NSString *)date
               tagIds:(NSArray<NSNumber *> *)tagIds
              success:(HTTPClientDiarySuccessBlock)success
              failure:(HTTPClientFailureBlock)failure;

- (void)deleteDiaryId:(NSInteger)diaryId
              success:(HTTPClientVoidSuccessBlock)success
              failure:(HTTPClientFailureBlock)failure;

- (void)fetchTagsWithSuccess:(HTTPClientTagListSuccessBlock)success
                     failure:(HTTPClientFailureBlock)failure;

- (void)createTagWithName:(NSString *)name
                  success:(HTTPClientTagSuccessBlock)success
                  failure:(HTTPClientFailureBlock)failure;

- (void)updateTagId:(NSInteger)tagId
               name:(NSString *)name
            success:(HTTPClientTagSuccessBlock)success
            failure:(HTTPClientFailureBlock)failure;

- (void)deleteTagId:(NSInteger)tagId
            success:(HTTPClientVoidSuccessBlock)success
            failure:(HTTPClientFailureBlock)failure;

@end

NS_ASSUME_NONNULL_END
