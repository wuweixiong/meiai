// BEGINNER GUIDE:
// File: XDJNetworkDefines.h
// Role: Network layer: wraps HTTP calls and translates API requests/responses.
// Reading tip: Read declarations in .h first, then implementation flow in .m.

// XindongrijiApp XDJNetworkDefines.h
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^XDJFailureBlock)(NSError *error, NSString *message);
typedef void(^XDJVoidSuccessBlock)(void);

NS_ASSUME_NONNULL_END
