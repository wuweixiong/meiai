// BEGINNER GUIDE:
// File: XDJCoreDataStack.m
// Role: Local storage layer: reads/writes Core Data cache for offline use.
// Reading tip: Read declarations in .h first, then implementation flow in .m.

// XindongrijiApp XDJCoreDataStack.m
#import "XDJCoreDataStack.h"

@implementation XDJCoreDataStack

+ (instancetype)sharedInstance {
    static XDJCoreDataStack *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[XDJCoreDataStack alloc] init];
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
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    NSLog(@"XindongrijiApp CoreData load error: %@", error.localizedDescription);
                }
            }];
            _persistentContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
            _persistentContainer.viewContext.automaticallyMergesChangesFromParent = YES;
        }
    }
    return _persistentContainer;
}

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    if (context.hasChanges) {
        NSError *error = nil;
        [context save:&error];
        if (error != nil) {
            NSLog(@"XindongrijiApp CoreData save error: %@", error.localizedDescription);
        }
    }
}

@end
