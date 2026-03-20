// BEGINNER GUIDE:
// File: TokenManager.m
// Role: Shared helper: reusable utilities used by multiple modules.
// Reading tip: Read declarations in .h first, then implementation flow in .m.

// XindongrijiApp TokenManager.m
#import "TokenManager.h"

static NSString * const kXDJTokenValueKey = @"XindongrijiApp.Token.Value";
static NSString * const kXDJTokenExpireAtKey = @"XindongrijiApp.Token.ExpireAt";

@implementation TokenManager

+ (instancetype)sharedManager {
    static TokenManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TokenManager alloc] init];
    });
    return instance;
}

- (void)saveToken:(NSString *)token expiresIn:(NSTimeInterval)expiresIn {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:token forKey:kXDJTokenValueKey];

    NSDate *expireAt = nil;
    if (expiresIn > 0) {
        expireAt = [NSDate dateWithTimeIntervalSinceNow:expiresIn];
        [defaults setObject:expireAt forKey:kXDJTokenExpireAtKey];
    } else {
        [defaults removeObjectForKey:kXDJTokenExpireAtKey];
    }
    [defaults synchronize];
}

- (NSString *)token {
    NSString *token = [[NSUserDefaults standardUserDefaults] stringForKey:kXDJTokenValueKey];
    return token.length > 0 ? token : nil;
}

- (BOOL)hasValidToken {
    NSString *token = [self token];
    if (token.length == 0) {
        return NO;
    }

    NSDate *expireAt = [[NSUserDefaults standardUserDefaults] objectForKey:kXDJTokenExpireAtKey];
    if (![expireAt isKindOfClass:[NSDate class]]) {
        return YES;
    }
    return [expireAt timeIntervalSinceNow] > 0;
}

- (NSString *)authorizationHeader {
    NSString *token = [self token];
    if (token.length == 0) {
        return nil;
    }
    return [NSString stringWithFormat:@"Bearer %@", token];
}

- (void)clearToken {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:kXDJTokenValueKey];
    [defaults removeObjectForKey:kXDJTokenExpireAtKey];
    [defaults synchronize];
}

@end
