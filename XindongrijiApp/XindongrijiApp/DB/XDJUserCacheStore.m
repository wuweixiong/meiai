// BEGINNER GUIDE:
// File: XDJUserCacheStore.m
// Role: Local storage layer: reads/writes Core Data cache for offline use.
// Reading tip: Read declarations in .h first, then implementation flow in .m.

// XindongrijiApp XDJUserCacheStore.m
#import "XDJUserCacheStore.h"
#import "XDJCoreDataStack.h"

@implementation XDJUserCacheStore

- (NSManagedObjectContext *)context {
    return [XDJCoreDataStack sharedInstance].persistentContainer.viewContext;
}

- (void)saveUser:(XDJUser *)user {
    NSManagedObjectContext *context = [self context];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"UserCache"];
    request.fetchLimit = 1;

    NSError *error = nil;
    NSManagedObject *row = [[context executeFetchRequest:request error:&error] firstObject];
    if (!row) {
        row = [NSEntityDescription insertNewObjectForEntityForName:@"UserCache" inManagedObjectContext:context];
    }

    [row setValue:@(user.userId) forKey:@"userId"];
    [row setValue:user.phone forKey:@"phone"];

    [[XDJCoreDataStack sharedInstance] saveContext];
}

- (XDJUser *)fetchCurrentUser {
    NSManagedObjectContext *context = [self context];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"UserCache"];
    request.fetchLimit = 1;

    NSError *error = nil;
    NSManagedObject *row = [[context executeFetchRequest:request error:&error] firstObject];
    if (!row) {
        return nil;
    }

    XDJUser *user = [[XDJUser alloc] init];
    user.userId = [[row valueForKey:@"userId"] integerValue];
    user.phone = [row valueForKey:@"phone"] ?: @"";
    return user;
}

- (void)clear {
    NSManagedObjectContext *context = [self context];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"UserCache"];

    NSError *error = nil;
    NSArray *rows = [context executeFetchRequest:request error:&error];
    for (NSManagedObject *row in rows) {
        [context deleteObject:row];
    }
    [[XDJCoreDataStack sharedInstance] saveContext];
}

@end
