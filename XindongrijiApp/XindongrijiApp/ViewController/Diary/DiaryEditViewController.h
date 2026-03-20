// BEGINNER GUIDE:
// File: DiaryEditViewController.h
// Role: UI layer: builds screens, handles taps, and calls services.
// Reading tip: Read declarations in .h first, then implementation flow in .m.

// XindongrijiApp DiaryEditViewController.h
#import <UIKit/UIKit.h>
#import "Model/DiaryModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface DiaryEditViewController : UIViewController

- (instancetype)initWithDiary:(nullable DiaryModel *)diary onSaved:(dispatch_block_t)onSaved;

@end

NS_ASSUME_NONNULL_END
