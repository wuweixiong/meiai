// BEGINNER GUIDE:
// File: DateUtils.m
// Role: Shared helper: reusable utilities used by multiple modules.
// Reading tip: Read declarations in .h first, then implementation flow in .m.

// XindongrijiApp DateUtils.m
#import "DateUtils.h"

@implementation DateUtils

+ (NSDateFormatter *)apiFormatter {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [NSLocale localeWithLocaleIdentifier:@"zh_CN"];
    formatter.dateFormat = @"yyyy-MM-dd";
    return formatter;
}

+ (NSDateFormatter *)displayFormatter {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [NSLocale localeWithLocaleIdentifier:@"zh_CN"];
    formatter.dateFormat = @"yyyy年MM月dd日";
    return formatter;
}

+ (NSString *)apiDateStringFromDate:(NSDate *)date {
    return [[self apiFormatter] stringFromDate:date];
}

+ (NSDate *)dateFromApiDateString:(NSString *)dateString {
    NSDate *date = [[self apiFormatter] dateFromString:dateString];
    return date ?: [NSDate date];
}

+ (NSString *)displayDateStringFromApiDateString:(NSString *)dateString {
    NSDate *date = [self dateFromApiDateString:dateString ?: @""];
    return [self displayDateStringFromDate:date];
}

+ (NSString *)displayDateStringFromDate:(NSDate *)date {
    return [[self displayFormatter] stringFromDate:date];
}

@end
