// BEGINNER GUIDE:
// File: CoreDataManager.h
// Role: Local storage layer: reads/writes Core Data cache for offline use.
// Reading tip: Read declarations in .h first, then implementation flow in .m.

// XindongrijiApp CoreDataManager.h
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Model/UserModel.h"
#import "Model/DiaryModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^CoreDataSyncCompletion)(NSInteger syncedCount, NSInteger remainingCount);

@interface CoreDataManager : NSObject

@property (readonly, strong) NSPersistentContainer *persistentContainer;

+ (instancetype)sharedManager;

- (void)saveContext;

// User cache
- (void)cacheCurrentUser:(UserModel *)user;
- (nullable UserModel *)cachedCurrentUser;

// Diary cache
- (void)cacheDiariesFromServer:(NSArray<DiaryModel *> *)diaries replaceAll:(BOOL)replaceAll;
- (NSArray<DiaryModel *> *)cachedDiariesSortedByDateDesc;
- (void)upsertDiary:(DiaryModel *)diary pendingAction:(nullable NSString *)pendingAction;
- (void)removeDiaryById:(NSInteger)diaryId;

// Pending operations for offline sync
- (void)enqueuePendingOperationType:(NSString *)type
                            payload:(NSDictionary *)payload
             replaceForLocalDiaryId:(nullable NSNumber *)localDiaryId;

- (void)removePendingOperationsForDiaryId:(NSInteger)diaryId;
- (void)syncPendingDiaryOperationsWithCompletion:(CoreDataSyncCompletion)completion;

- (void)clearAllCache;

@end

NS_ASSUME_NONNULL_END
