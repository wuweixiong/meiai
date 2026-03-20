// BEGINNER GUIDE:
// File: DateUtils.h
// Role: Shared helper: reusable utilities used by multiple modules.
// Reading tip: Read declarations in .h first, then implementation flow in .m.

// XindongrijiApp DateUtils.h
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DateUtils : NSObject

+ (NSString *)apiDateStringFromDate:(NSDate *)date;
+ (NSDate *)dateFromApiDateString:(NSString *)dateString;
+ (NSString *)displayDateStringFromApiDateString:(NSString *)dateString;
+ (NSString *)displayDateStringFromDate:(NSDate *)date;

@end

NS_ASSUME_NONNULL_END
