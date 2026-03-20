// BEGINNER GUIDE:
// File: TagModel.m
// Role: Data model: describes app data structure used across layers.
// Reading tip: Read declarations in .h first, then implementation flow in .m.

// XindongrijiApp TagModel.m
#import "TagModel.h"
#import <MJExtension/MJExtension.h>

@implementation TagModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{@"tagId": @"id"};
}

@end
