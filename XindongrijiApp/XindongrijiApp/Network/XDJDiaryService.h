// BEGINNER GUIDE:
// File: XDJDiaryService.h
// Role: Network layer: wraps HTTP calls and translates API requests/responses.
// Reading tip: Read declarations in .h first, then implementation flow in .m.

// XindongrijiApp XDJDiaryService.h
#import <Foundation/Foundation.h>
#import "Model/XDJDiary.h"
#import "XDJNetworkDefines.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^XDJDiaryListSuccessBlock)(NSArray<XDJDiary *> *items, NSInteger total);
typedef void(^XDJDiarySuccessBlock)(XDJDiary *diary);

@interface XDJDiaryService : NSObject

- (void)fetchDiariesWithPage:(NSInteger)page
                        size:(NSInteger)size
                     success:(XDJDiaryListSuccessBlock)success
                     failure:(XDJFailureBlock)failure;

- (void)createDiaryWithTitle:(NSString *)title
                     content:(NSString *)content
                        date:(NSString *)date
                      tagIds:(NSArray<NSNumber *> *)tagIds
                     success:(XDJDiarySuccessBlock)success
                     failure:(XDJFailureBlock)failure;

- (void)updateDiaryId:(NSInteger)diaryId
                title:(NSString *)title
              content:(NSString *)content
                 date:(NSString *)date
               tagIds:(NSArray<NSNumber *> *)tagIds
              success:(XDJDiarySuccessBlock)success
              failure:(XDJFailureBlock)failure;

- (void)deleteDiaryId:(NSInteger)diaryId
              success:(XDJVoidSuccessBlock)success
              failure:(XDJFailureBlock)failure;

@end

NS_ASSUME_NONNULL_END
