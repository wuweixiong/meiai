// BEGINNER GUIDE:
// File: XDJDiaryService.m
// Role: Network layer: wraps HTTP calls and translates API requests/responses.
// Reading tip: Read declarations in .h first, then implementation flow in .m.

// XindongrijiApp XDJDiaryService.m
#import "XDJDiaryService.h"
#import "XDJAPIClient.h"
#import <MJExtension/MJExtension.h>

@implementation XDJDiaryService

- (void)fetchDiariesWithPage:(NSInteger)page size:(NSInteger)size success:(XDJDiaryListSuccessBlock)success failure:(XDJFailureBlock)failure {
    NSDictionary *params = @{ @"page": @(page), @"size": @(size) };
    [[XDJAPIClient sharedClient] GET:@"/diaries" parameters:params success:^(id data) {
        NSArray *itemsJSON = [data isKindOfClass:[NSDictionary class]] ? data[@"items"] : @[];
        NSArray<XDJDiary *> *items = [XDJDiary mj_objectArrayWithKeyValuesArray:itemsJSON];
        NSInteger total = [data[@"total"] integerValue];
        success(items, total);
    } failure:failure];
}

- (void)createDiaryWithTitle:(NSString *)title content:(NSString *)content date:(NSString *)date tagIds:(NSArray<NSNumber *> *)tagIds success:(XDJDiarySuccessBlock)success failure:(XDJFailureBlock)failure {
    NSDictionary *params = @{ @"title": title ?: @"", @"content": content ?: @"", @"date": date ?: @"", @"tagIds": tagIds ?: @[] };
    [[XDJAPIClient sharedClient] POST:@"/diaries" parameters:params success:^(id data) {
        XDJDiary *diary = [XDJDiary mj_objectWithKeyValues:data];
        success(diary);
    } failure:failure];
}

- (void)updateDiaryId:(NSInteger)diaryId title:(NSString *)title content:(NSString *)content date:(NSString *)date tagIds:(NSArray<NSNumber *> *)tagIds success:(XDJDiarySuccessBlock)success failure:(XDJFailureBlock)failure {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (title.length > 0) { params[@"title"] = title; }
    if (content.length > 0) { params[@"content"] = content; }
    if (date.length > 0) { params[@"date"] = date; }
    if (tagIds) { params[@"tagIds"] = tagIds; }

    NSString *path = [NSString stringWithFormat:@"/diaries/%ld", (long)diaryId];
    [[XDJAPIClient sharedClient] PUT:path parameters:params success:^(id data) {
        XDJDiary *diary = [XDJDiary mj_objectWithKeyValues:data];
        success(diary);
    } failure:failure];
}

- (void)deleteDiaryId:(NSInteger)diaryId success:(XDJVoidSuccessBlock)success failure:(XDJFailureBlock)failure {
    NSString *path = [NSString stringWithFormat:@"/diaries/%ld", (long)diaryId];
    [[XDJAPIClient sharedClient] DELETE:path parameters:nil success:^(id data) {
        success();
    } failure:failure];
}

@end
