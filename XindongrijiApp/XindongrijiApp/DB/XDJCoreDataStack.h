// BEGINNER GUIDE:
// File: XDJCoreDataStack.h
// Role: Local storage layer: reads/writes Core Data cache for offline use.
// Reading tip: Read declarations in .h first, then implementation flow in .m.

// XindongrijiApp XDJCoreDataStack.h
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface XDJCoreDataStack : NSObject

@property (readonly, strong) NSPersistentContainer *persistentContainer;

+ (instancetype)sharedInstance;
- (void)saveContext;

@end

NS_ASSUME_NONNULL_END
