// BEGINNER GUIDE:
// File: XDJDiary.h
// Role: Data model: describes app data structure used across layers.
// Reading tip: Read declarations in .h first, then implementation flow in .m.

// XindongrijiApp XDJDiary.h
#import <Foundation/Foundation.h>
#import "XDJTag.h"

NS_ASSUME_NONNULL_BEGIN

@interface XDJDiary : NSObject

@property (nonatomic, assign) NSInteger diaryId;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *date;
@property (nonatomic, strong) NSArray<XDJTag *> *tags;
@property (nonatomic, copy, nullable) NSString *createdAt;

@end

NS_ASSUME_NONNULL_END
