// BEGINNER GUIDE:
// File: DiaryModel.h
// Role: Data model: describes app data structure used across layers.
// Reading tip: Read declarations in .h first, then implementation flow in .m.

// XindongrijiApp DiaryModel.h
#import <Foundation/Foundation.h>
#import "TagModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface DiaryModel : NSObject

@property (nonatomic, assign) NSInteger diaryId;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *date;
@property (nonatomic, copy, nullable) NSString *createdAt;
@property (nonatomic, strong) NSArray<TagModel *> *tags;

- (NSArray<NSNumber *> *)tagIds;

@end

NS_ASSUME_NONNULL_END
