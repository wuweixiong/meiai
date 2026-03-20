// BEGINNER GUIDE:
// File: XDJTagService.h
// Role: Network layer: wraps HTTP calls and translates API requests/responses.
// Reading tip: Read declarations in .h first, then implementation flow in .m.

// XindongrijiApp XDJTagService.h
#import <Foundation/Foundation.h>
#import "Model/XDJTag.h"
#import "XDJNetworkDefines.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^XDJTagListSuccessBlock)(NSArray<XDJTag *> *items);
typedef void(^XDJTagSuccessBlock)(XDJTag *tag);

@interface XDJTagService : NSObject

- (void)fetchTagsWithSuccess:(XDJTagListSuccessBlock)success
                     failure:(XDJFailureBlock)failure;

- (void)createTagWithName:(NSString *)name
                  success:(XDJTagSuccessBlock)success
                  failure:(XDJFailureBlock)failure;

- (void)updateTagWithId:(NSInteger)tagId
                   name:(NSString *)name
                success:(XDJTagSuccessBlock)success
                failure:(XDJFailureBlock)failure;

- (void)deleteTagWithId:(NSInteger)tagId
                success:(XDJVoidSuccessBlock)success
                failure:(XDJFailureBlock)failure;

@end

NS_ASSUME_NONNULL_END
