// BEGINNER GUIDE:
// File: XDJDiary.m
// Role: Data model: describes app data structure used across layers.
// Reading tip: Read declarations in .h first, then implementation flow in .m.

// XindongrijiApp XDJDiary.m
#import "XDJDiary.h"
#import <MJExtension/MJExtension.h>

@implementation XDJDiary

+ (NSDictionary *)mj_objectClassInArray {
    return @{ @"tags": [XDJTag class] };
}

@end
