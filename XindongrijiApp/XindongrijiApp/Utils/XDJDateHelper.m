// BEGINNER GUIDE:
// File: XDJDateHelper.m
// Role: Shared helper: reusable utilities used by multiple modules.
// Reading tip: Read declarations in .h first, then implementation flow in .m.

// XindongrijiApp XDJDateHelper.m
#import "XDJDateHelper.h"

@implementation XDJDateHelper

+ (NSDateFormatter *)apiFormatter {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";
    formatter.locale = [NSLocale localeWithLocaleIdentifier:@"zh_CN"];
    return formatter;
}

+ (NSDateFormatter *)displayFormatter {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy年MM月dd日";
    formatter.locale = [NSLocale localeWithLocaleIdentifier:@"zh_CN"];
    return formatter;
}

+ (NSString *)apiDateStringFromDate:(NSDate *)date {
    return [[self apiFormatter] stringFromDate:date];
}

+ (NSDate *)dateFromApiDateString:(NSString *)dateString {
    NSDate *date = [[self apiFormatter] dateFromString:dateString];
    return date ?: [NSDate date];
}

+ (NSString *)displayDateStringFromDate:(NSDate *)date {
    return [[self displayFormatter] stringFromDate:date];
}

@end
