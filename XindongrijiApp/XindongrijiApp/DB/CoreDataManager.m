// BEGINNER GUIDE:
// File: CoreDataManager.m
// Role: Local storage layer: reads/writes Core Data cache for offline use.
// Reading tip: Read declarations in .h first, then implementation flow in .m.

// XindongrijiApp CoreDataManager.m
#import "CoreDataManager.h"
#import <AFNetworking/AFNetworking.h>
#import "Network/HTTPClient.h"
#import <MJExtension/MJExtension.h>

static NSString * const kDiaryEntity = @"DiaryCache";
static NSString * const kUserEntity = @"UserCache";
static NSString * const kPendingEntity = @"PendingDiaryOperation";

static NSString * const kPendingCreate = @"create";
static NSString * const kPendingUpdate = @"update";
static NSString * const kPendingDelete = @"delete";

@interface CoreDataManager ()

@property (readonly, strong) NSPersistentContainer *persistentContainer;

@end

@implementation CoreDataManager

+ (instancetype)sharedManager {
    static CoreDataManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[CoreDataManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self persistentContainer];
    }
    return self;
}

- (NSPersistentContainer *)persistentContainer {
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"XindongrijiApp"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *desc, NSError *error) {
                if (error) {
                    NSLog(@"XindongrijiApp CoreData load error: %@", error.localizedDescription);
                }
            }];
            _persistentContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
            _persistentContainer.viewContext.automaticallyMergesChangesFromParent = YES;
        }
    }
    return _persistentContainer;
}

- (NSManagedObjectContext *)context {
    return self.persistentContainer.viewContext;
}

- (void)saveContext {
    NSManagedObjectContext *context = [self context];
    if (!context.hasChanges) {
        return;
    }

    NSError *error = nil;
    [context save:&error];
    if (error) {
        NSLog(@"XindongrijiApp CoreData save error: %@", error.localizedDescription);
    }
}

#pragma mark - User

- (void)cacheCurrentUser:(UserModel *)user {
    NSManagedObjectContext *context = [self context];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:kUserEntity];
    request.fetchLimit = 1;

    NSError *error = nil;
    NSManagedObject *row = [[context executeFetchRequest:request error:&error] firstObject];
    if (!row) {
        row = [NSEntityDescription insertNewObjectForEntityForName:kUserEntity inManagedObjectContext:context];
    }

    [row setValue:@(user.userId) forKey:@"userId"];
    [row setValue:user.phone ?: @"" forKey:@"phone"];
    [row setValue:[NSDate date] forKey:@"updatedAt"];
    [self saveContext];
}

- (UserModel *)cachedCurrentUser {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:kUserEntity];
    request.fetchLimit = 1;

    NSError *error = nil;
    NSManagedObject *row = [[[self context] executeFetchRequest:request error:&error] firstObject];
    if (!row) {
        return nil;
    }

    UserModel *user = [[UserModel alloc] init];
    user.userId = [[row valueForKey:@"userId"] integerValue];
    user.phone = [row valueForKey:@"phone"] ?: @"";
    return user;
}

#pragma mark - Diary cache

- (void)cacheDiariesFromServer:(NSArray<DiaryModel *> *)diaries replaceAll:(BOOL)replaceAll {
    NSManagedObjectContext *context = [self context];

    if (replaceAll) {
        // Keep locally pending diaries; clear only confirmed server cache.
        NSFetchRequest *clearRequest = [NSFetchRequest fetchRequestWithEntityName:kDiaryEntity];
        clearRequest.predicate = [NSPredicate predicateWithFormat:@"pendingAction == nil OR pendingAction == ''"];
        NSArray<NSManagedObject *> *rows = [context executeFetchRequest:clearRequest error:nil];
        for (NSManagedObject *row in rows) {
            [context deleteObject:row];
        }
    }

    for (DiaryModel *diary in diaries) {
        NSManagedObject *row = [self fetchDiaryRowById:diary.diaryId context:context];
        NSString *pendingAction = [row valueForKey:@"pendingAction"];
        if (pendingAction.length > 0) {
            // Keep local pending edit content.
            continue;
        }
        [self applyDiary:diary toRow:row pendingAction:nil];
    }
    [self saveContext];
}

- (NSArray<DiaryModel *> *)cachedDiariesSortedByDateDesc {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:kDiaryEntity];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO], [NSSortDescriptor sortDescriptorWithKey:@"updatedAt" ascending:NO]];

    NSError *error = nil;
    NSArray<NSManagedObject *> *rows = [[self context] executeFetchRequest:request error:&error];
    if (error) {
        return @[];
    }

    NSMutableArray<DiaryModel *> *result = [NSMutableArray array];
    for (NSManagedObject *row in rows) {
        [result addObject:[self diaryFromRow:row]];
    }
    return result;
}

- (void)upsertDiary:(DiaryModel *)diary pendingAction:(NSString *)pendingAction {
    NSManagedObject *row = [self fetchDiaryRowById:diary.diaryId context:[self context]];
    [self applyDiary:diary toRow:row pendingAction:pendingAction];
    [self saveContext];
}

- (void)removeDiaryById:(NSInteger)diaryId {
    NSManagedObjectContext *context = [self context];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:kDiaryEntity];
    request.predicate = [NSPredicate predicateWithFormat:@"diaryId == %ld", (long)diaryId];

    NSArray<NSManagedObject *> *rows = [context executeFetchRequest:request error:nil];
    for (NSManagedObject *row in rows) {
        [context deleteObject:row];
    }
    [self saveContext];
}

#pragma mark - Pending queue

- (void)enqueuePendingOperationType:(NSString *)type payload:(NSDictionary *)payload replaceForLocalDiaryId:(NSNumber *)localDiaryId {
    if (localDiaryId) {
        [self removePendingOperationsForDiaryId:[localDiaryId integerValue]];
    }

    NSData *payloadData = [NSJSONSerialization dataWithJSONObject:payload options:0 error:nil];
    NSManagedObject *row = [NSEntityDescription insertNewObjectForEntityForName:kPendingEntity inManagedObjectContext:[self context]];
    [row setValue:NSUUID.UUID.UUIDString forKey:@"operationId"];
    [row setValue:type forKey:@"type"];
    [row setValue:payloadData forKey:@"payloadJson"];
    [row setValue:[NSDate date] forKey:@"createdAt"];
    [self saveContext];
}

- (void)removePendingOperationsForDiaryId:(NSInteger)diaryId {
    NSManagedObjectContext *context = [self context];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:kPendingEntity];
    NSArray<NSManagedObject *> *rows = [context executeFetchRequest:request error:nil];

    for (NSManagedObject *row in rows) {
        NSDictionary *payload = [self payloadFromPendingRow:row];
        NSInteger localId = [payload[@"localDiaryId"] integerValue];
        NSInteger remoteId = [payload[@"diaryId"] integerValue];
        if (localId == diaryId || remoteId == diaryId) {
            [context deleteObject:row];
        }
    }
    [self saveContext];
}

- (void)syncPendingDiaryOperationsWithCompletion:(CoreDataSyncCompletion)completion {
    if (![self isNetworkReachable]) {
        NSInteger remainCount = [self pendingRows].count;
        completion(0, remainCount);
        return;
    }

    NSArray<NSManagedObject *> *rows = [self pendingRows];
    if (rows.count == 0) {
        completion(0, 0);
        return;
    }

    [self syncPendingRows:rows syncedCount:0 completion:completion];
}

- (void)syncPendingRows:(NSArray<NSManagedObject *> *)rows
            syncedCount:(NSInteger)syncedCount
             completion:(CoreDataSyncCompletion)completion {
    if (rows.count == 0) {
        NSInteger remainCount = [self pendingRows].count;
        completion(syncedCount, remainCount);
        return;
    }

    NSManagedObject *row = rows.firstObject;
    NSString *type = [row valueForKey:@"type"] ?: @"";
    NSDictionary *payload = [self payloadFromPendingRow:row];

    __weak typeof(self) weakSelf = self;
    void (^onSuccess)(void) = ^{
        __strong typeof(weakSelf) self = weakSelf;
        [[self context] deleteObject:row];
        [self saveContext];

        NSMutableArray<NSManagedObject *> *remaining = [rows mutableCopy];
        [remaining removeObjectAtIndex:0];
        [self syncPendingRows:remaining syncedCount:syncedCount + 1 completion:completion];
    };

    void (^onFailure)(void) = ^{
        __strong typeof(weakSelf) self = weakSelf;
        NSInteger remainCount = [self pendingRows].count;
        completion(syncedCount, remainCount);
    };

    HTTPClient *client = [HTTPClient sharedClient];

    if ([type isEqualToString:kPendingCreate]) {
        NSString *title = payload[@"title"] ?: @"";
        NSString *content = payload[@"content"] ?: @"";
        NSString *date = payload[@"date"] ?: @"";
        NSArray<NSNumber *> *tagIds = payload[@"tagIds"] ?: @[];
        NSInteger localDiaryId = [payload[@"localDiaryId"] integerValue];

        [client createDiaryWithTitle:title content:content date:date tagIds:tagIds success:^(DiaryModel *diary) {
            if (localDiaryId != 0) {
                [weakSelf removeDiaryById:localDiaryId];
            }
            [weakSelf upsertDiary:diary pendingAction:nil];
            onSuccess();
        } failure:^(NSError *error, NSString *message, NSInteger code) {
            onFailure();
        }];

        return;
    }

    if ([type isEqualToString:kPendingUpdate]) {
        NSInteger diaryId = [payload[@"diaryId"] integerValue];
        NSString *title = payload[@"title"] ?: @"";
        NSString *content = payload[@"content"] ?: @"";
        NSString *date = payload[@"date"] ?: @"";
        NSArray<NSNumber *> *tagIds = payload[@"tagIds"] ?: @[];

        [client updateDiaryId:diaryId title:title content:content date:date tagIds:tagIds success:^(DiaryModel *diary) {
            [weakSelf upsertDiary:diary pendingAction:nil];
            onSuccess();
        } failure:^(NSError *error, NSString *message, NSInteger code) {
            onFailure();
        }];

        return;
    }

    if ([type isEqualToString:kPendingDelete]) {
        NSInteger diaryId = [payload[@"diaryId"] integerValue];
        [client deleteDiaryId:diaryId success:^{
            onSuccess();
        } failure:^(NSError *error, NSString *message, NSInteger code) {
            onFailure();
        }];
        return;
    }

    // Unknown type, remove invalid record.
    [[self context] deleteObject:row];
    [self saveContext];
    NSMutableArray<NSManagedObject *> *remaining = [rows mutableCopy];
    [remaining removeObjectAtIndex:0];
    [self syncPendingRows:remaining syncedCount:syncedCount completion:completion];
}

- (NSArray<NSManagedObject *> *)pendingRows {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:kPendingEntity];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES]];
    return [[self context] executeFetchRequest:request error:nil] ?: @[];
}

#pragma mark - Helpers

- (BOOL)isNetworkReachable {
    AFNetworkReachabilityStatus status = AFNetworkReachabilityManager.sharedManager.networkReachabilityStatus;
    return status == AFNetworkReachabilityStatusReachableViaWWAN || status == AFNetworkReachabilityStatusReachableViaWiFi;
}

- (NSDictionary *)payloadFromPendingRow:(NSManagedObject *)row {
    NSData *data = [row valueForKey:@"payloadJson"];
    if (!data) {
        return @{};
    }
    NSDictionary *payload = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    return [payload isKindOfClass:[NSDictionary class]] ? payload : @{};
}

- (NSManagedObject *)fetchDiaryRowById:(NSInteger)diaryId context:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:kDiaryEntity];
    request.fetchLimit = 1;
    request.predicate = [NSPredicate predicateWithFormat:@"diaryId == %ld", (long)diaryId];

    NSManagedObject *row = [[context executeFetchRequest:request error:nil] firstObject];
    if (!row) {
        row = [NSEntityDescription insertNewObjectForEntityForName:kDiaryEntity inManagedObjectContext:context];
    }
    return row;
}

- (void)applyDiary:(DiaryModel *)diary toRow:(NSManagedObject *)row pendingAction:(NSString *)pendingAction {
    [row setValue:@(diary.diaryId) forKey:@"diaryId"];
    [row setValue:diary.title ?: @"" forKey:@"title"];
    [row setValue:diary.content ?: @"" forKey:@"content"];
    [row setValue:diary.date ?: @"" forKey:@"date"];
    [row setValue:diary.createdAt ?: @"" forKey:@"createdAt"];

    NSMutableArray<NSDictionary *> *tagDictionaries = [NSMutableArray array];
    for (TagModel *tag in diary.tags) {
        [tagDictionaries addObject:@{@"id": @(tag.tagId), @"name": tag.name ?: @""}];
    }

    NSData *tagsData = [NSJSONSerialization dataWithJSONObject:tagDictionaries options:0 error:nil];
    [row setValue:tagsData forKey:@"tagsJson"];

    if (pendingAction.length > 0) {
        [row setValue:pendingAction forKey:@"pendingAction"];
    } else {
        [row setValue:nil forKey:@"pendingAction"];
    }
    [row setValue:[NSDate date] forKey:@"updatedAt"];
}

- (DiaryModel *)diaryFromRow:(NSManagedObject *)row {
    DiaryModel *diary = [[DiaryModel alloc] init];
    diary.diaryId = [[row valueForKey:@"diaryId"] integerValue];
    diary.title = [row valueForKey:@"title"] ?: @"";
    diary.content = [row valueForKey:@"content"] ?: @"";
    diary.date = [row valueForKey:@"date"] ?: @"";
    diary.createdAt = [row valueForKey:@"createdAt"];

    NSData *tagsData = [row valueForKey:@"tagsJson"];
    NSArray *tagDictionaries = tagsData ? [NSJSONSerialization JSONObjectWithData:tagsData options:0 error:nil] : @[];
    diary.tags = [TagModel mj_objectArrayWithKeyValuesArray:tagDictionaries ?: @[]];
    return diary;
}

- (void)clearAllCache {
    NSManagedObjectContext *context = [self context];
    NSArray<NSString *> *entities = @[kDiaryEntity, kUserEntity, kPendingEntity];
    for (NSString *entityName in entities) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
        NSArray<NSManagedObject *> *rows = [context executeFetchRequest:request error:nil];
        for (NSManagedObject *row in rows) {
            [context deleteObject:row];
        }
    }
    [self saveContext];
}

@end
