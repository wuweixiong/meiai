// BEGINNER GUIDE:
// File: DiaryEditorViewController.h
// Role: UI layer: builds screens, handles taps, and calls services.
// Reading tip: Read declarations in .h first, then implementation flow in .m.

// XindongrijiApp DiaryEditorViewController.h
#import <UIKit/UIKit.h>
#import "Model/XDJDiary.h"

NS_ASSUME_NONNULL_BEGIN

@interface DiaryEditorViewController : UIViewController

- (instancetype)initWithDiary:(nullable XDJDiary *)diary submitSuccessBlock:(dispatch_block_t)submitSuccessBlock;

@end

NS_ASSUME_NONNULL_END
