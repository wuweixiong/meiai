// BEGINNER GUIDE:
// File: XDJTagService.m
// Role: Network layer: wraps HTTP calls and translates API requests/responses.
// Reading tip: Read declarations in .h first, then implementation flow in .m.

// XindongrijiApp XDJTagService.m
#import "XDJTagService.h"
#import "XDJAPIClient.h"
#import <MJExtension/MJExtension.h>

@implementation XDJTagService

- (void)fetchTagsWithSuccess:(XDJTagListSuccessBlock)success failure:(XDJFailureBlock)failure {
    [[XDJAPIClient sharedClient] GET:@"/tags" parameters:nil success:^(id data) {
        NSArray<XDJTag *> *items = [XDJTag mj_objectArrayWithKeyValuesArray:data];
        success(items);
    } failure:failure];
}

- (void)createTagWithName:(NSString *)name success:(XDJTagSuccessBlock)success failure:(XDJFailureBlock)failure {
    NSDictionary *params = @{ @"name": name ?: @"" };
    [[XDJAPIClient sharedClient] POST:@"/tags" parameters:params success:^(id data) {
        XDJTag *tag = [XDJTag mj_objectWithKeyValues:data];
        success(tag);
    } failure:failure];
}

- (void)updateTagWithId:(NSInteger)tagId name:(NSString *)name success:(XDJTagSuccessBlock)success failure:(XDJFailureBlock)failure {
    NSDictionary *params = @{ @"name": name ?: @"" };
    NSString *path = [NSString stringWithFormat:@"/tags/%ld", (long)tagId];
    [[XDJAPIClient sharedClient] PUT:path parameters:params success:^(id data) {
        XDJTag *tag = [XDJTag mj_objectWithKeyValues:data];
        success(tag);
    } failure:failure];
}

- (void)deleteTagWithId:(NSInteger)tagId success:(XDJVoidSuccessBlock)success failure:(XDJFailureBlock)failure {
    NSString *path = [NSString stringWithFormat:@"/tags/%ld", (long)tagId];
    [[XDJAPIClient sharedClient] DELETE:path parameters:nil success:^(id data) {
        success();
    } failure:failure];
}

@end
