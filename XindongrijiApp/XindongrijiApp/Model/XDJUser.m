// BEGINNER GUIDE:
// File: XDJUser.m
// Role: Data model: describes app data structure used across layers.
// Reading tip: Read declarations in .h first, then implementation flow in .m.

// XindongrijiApp XDJUser.m
#import "XDJUser.h"
#import <MJExtension/MJExtension.h>

@implementation XDJUser

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{ @"userId": @"userId" };
}

@end
