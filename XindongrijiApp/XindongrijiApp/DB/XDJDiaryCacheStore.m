// BEGINNER GUIDE:
// File: XDJDiaryCacheStore.m
// Role: Local storage layer: reads/writes Core Data cache for offline use.
// Reading tip: Read declarations in .h first, then implementation flow in .m.

// XindongrijiApp XDJDiaryCacheStore.m
#import "XDJDiaryCacheStore.h"
#import "XDJCoreDataStack.h"
#import "Model/XDJTag.h"

@implementation XDJDiaryCacheStore

- (NSManagedObjectContext *)context {
    return [XDJCoreDataStack sharedInstance].persistentContainer.viewContext;
}

- (void)saveDiaries:(NSArray<XDJDiary *> *)diaries {
    NSManagedObjectContext *context = [self context];
    for (XDJDiary *diary in diaries) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"DiaryCache"]; 
        request.predicate = [NSPredicate predicateWithFormat:@"diaryId == %ld", (long)diary.diaryId];
        request.fetchLimit = 1;

        NSError *fetchError = nil;
        NSManagedObject *object = [[context executeFetchRequest:request error:&fetchError] firstObject];
        if (!object) {
            object = [NSEntityDescription insertNewObjectForEntityForName:@"DiaryCache" inManagedObjectContext:context];
        }

        [object setValue:@(diary.diaryId) forKey:@"diaryId"];
        [object setValue:diary.title forKey:@"title"];
        [object setValue:diary.content forKey:@"content"];
        [object setValue:diary.date forKey:@"date"];

        NSMutableArray<NSString *> *tagNames = [NSMutableArray array];
        for (XDJTag *tag in diary.tags) {
            [tagNames addObject:tag.name ?: @""];
        }
        NSData *tagData = [NSJSONSerialization dataWithJSONObject:tagNames options:0 error:nil];
        [object setValue:tagData forKey:@"tagNamesJson"];
    }

    [[XDJCoreDataStack sharedInstance] saveContext];
}

- (NSArray<XDJDiary *> *)fetchDiaries {
    NSManagedObjectContext *context = [self context];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"DiaryCache"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]];

    NSError *error = nil;
    NSArray<NSManagedObject *> *rows = [context executeFetchRequest:request error:&error];
    if (error) {
        return @[];
    }

    NSMutableArray<XDJDiary *> *result = [NSMutableArray array];
    for (NSManagedObject *row in rows) {
        XDJDiary *diary = [[XDJDiary alloc] init];
        diary.diaryId = [[row valueForKey:@"diaryId"] integerValue];
        diary.title = [row valueForKey:@"title"] ?: @"";
        diary.content = [row valueForKey:@"content"] ?: @"";
        diary.date = [row valueForKey:@"date"] ?: @"";

        NSData *tagData = [row valueForKey:@"tagNamesJson"];
        NSArray *names = @[];
        if (tagData) {
            names = [NSJSONSerialization JSONObjectWithData:tagData options:0 error:nil] ?: @[];
        }

        NSMutableArray<XDJTag *> *tags = [NSMutableArray array];
        for (NSString *name in names) {
            XDJTag *tag = [[XDJTag alloc] init];
            tag.name = name;
            [tags addObject:tag];
        }
        diary.tags = tags;
        [result addObject:diary];
    }

    return result;
}

- (void)deleteDiaryId:(NSInteger)diaryId {
    NSManagedObjectContext *context = [self context];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"DiaryCache"];
    request.predicate = [NSPredicate predicateWithFormat:@"diaryId == %ld", (long)diaryId];

    NSError *error = nil;
    NSArray *rows = [context executeFetchRequest:request error:&error];
    for (NSManagedObject *row in rows) {
        [context deleteObject:row];
    }
    [[XDJCoreDataStack sharedInstance] saveContext];
}

@end
