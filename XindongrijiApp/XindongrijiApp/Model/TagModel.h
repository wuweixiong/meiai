// BEGINNER GUIDE:
// File: TagModel.h
// Role: Data model: describes app data structure used across layers.
// Reading tip: Read declarations in .h first, then implementation flow in .m.

// XindongrijiApp TagModel.h
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TagModel : NSObject

@property (nonatomic, assign) NSInteger tagId;
@property (nonatomic, copy) NSString *name;

@end

NS_ASSUME_NONNULL_END
