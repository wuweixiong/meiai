// BEGINNER GUIDE:
// File: XDJDiaryCacheStore.h
// Role: Local storage layer: reads/writes Core Data cache for offline use.
// Reading tip: Read declarations in .h first, then implementation flow in .m.

// XindongrijiApp XDJDiaryCacheStore.h
#import <Foundation/Foundation.h>
#import "Model/XDJDiary.h"

NS_ASSUME_NONNULL_BEGIN

@interface XDJDiaryCacheStore : NSObject

- (void)saveDiaries:(NSArray<XDJDiary *> *)diaries;
- (NSArray<XDJDiary *> *)fetchDiaries;
- (void)deleteDiaryId:(NSInteger)diaryId;

@end

NS_ASSUME_NONNULL_END
