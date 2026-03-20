// BEGINNER GUIDE:
// File: XDJPageResponse.h
// Role: Data model: describes app data structure used across layers.
// Reading tip: Read declarations in .h first, then implementation flow in .m.

// XindongrijiApp XDJPageResponse.h
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XDJPageResponse : NSObject

@property (nonatomic, strong) NSArray *items;
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) NSInteger size;
@property (nonatomic, assign) NSInteger total;

@end

NS_ASSUME_NONNULL_END
