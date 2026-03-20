// BEGINNER GUIDE:
// File: XDJBaseResponse.h
// Role: Data model: describes app data structure used across layers.
// Reading tip: Read declarations in .h first, then implementation flow in .m.

// XindongrijiApp XDJBaseResponse.h
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XDJBaseResponse : NSObject

@property (nonatomic, assign) NSInteger code;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, strong) id data;

@end

NS_ASSUME_NONNULL_END
