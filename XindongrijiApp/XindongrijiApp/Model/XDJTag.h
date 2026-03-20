// BEGINNER GUIDE:
// File: XDJTag.h
// Role: Data model: describes app data structure used across layers.
// Reading tip: Read declarations in .h first, then implementation flow in .m.

// XindongrijiApp XDJTag.h
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XDJTag : NSObject

@property (nonatomic, assign) NSInteger id;
@property (nonatomic, copy) NSString *name;

@end

NS_ASSUME_NONNULL_END
