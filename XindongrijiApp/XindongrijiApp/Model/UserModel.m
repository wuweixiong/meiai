// BEGINNER GUIDE:
// File: UserModel.m
// Role: Data model: describes app data structure used across layers.
// Reading tip: Read declarations in .h first, then implementation flow in .m.

// XindongrijiApp UserModel.m
#import "UserModel.h"
#import <MJExtension/MJExtension.h>

@implementation UserModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{@"userId": @"userId"};
}

@end
