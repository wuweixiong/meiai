// BEGINNER GUIDE:
// File: XDJUserCacheStore.h
// Role: Local storage layer: reads/writes Core Data cache for offline use.
// Reading tip: Read declarations in .h first, then implementation flow in .m.

// XindongrijiApp XDJUserCacheStore.h
#import <Foundation/Foundation.h>
#import "Model/XDJUser.h"

NS_ASSUME_NONNULL_BEGIN

@interface XDJUserCacheStore : NSObject

- (void)saveUser:(XDJUser *)user;
- (nullable XDJUser *)fetchCurrentUser;
- (void)clear;

@end

NS_ASSUME_NONNULL_END
