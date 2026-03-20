// BEGINNER GUIDE:
// File: DiaryModel.m
// Role: Data model: describes app data structure used across layers.
// Reading tip: Read declarations in .h first, then implementation flow in .m.

// XindongrijiApp DiaryModel.m
#import "DiaryModel.h"
#import <MJExtension/MJExtension.h>

@implementation DiaryModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{@"diaryId": @"diaryId"};
}

+ (NSDictionary *)mj_objectClassInArray {
    return @{@"tags": [TagModel class]};
}

- (NSArray<NSNumber *> *)tagIds {
    NSMutableArray<NSNumber *> *ids = [NSMutableArray array];
    for (TagModel *tag in self.tags) {
        [ids addObject:@(tag.tagId)];
    }
    return ids;
}

@end
