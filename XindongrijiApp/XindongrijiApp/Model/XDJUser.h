// BEGINNER GUIDE:
// File: XDJUser.h
// Role: Data model: describes app data structure used across layers.
// Reading tip: Read declarations in .h first, then implementation flow in .m.

// XindongrijiApp XDJUser.h
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XDJUser : NSObject

@property (nonatomic, assign) NSInteger userId;
@property (nonatomic, copy) NSString *phone;

@end

NS_ASSUME_NONNULL_END
