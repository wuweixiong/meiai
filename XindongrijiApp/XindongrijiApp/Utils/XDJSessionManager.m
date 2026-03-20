// BEGINNER GUIDE:
// File: XDJSessionManager.m
// Role: Shared helper: reusable utilities used by multiple modules.
// Reading tip: Read declarations in .h first, then implementation flow in .m.

// XindongrijiApp XDJSessionManager.m
#import "XDJSessionManager.h"

static NSString * const kXDJAccessTokenKey = @"XindongrijiApp.AccessToken";
static NSString * const kXDJPhoneKey = @"XindongrijiApp.Phone";

@interface XDJSessionManager ()

@property (nonatomic, copy, nullable, readwrite) NSString *accessToken;
@property (nonatomic, copy, nullable, readwrite) NSString *phone;

@end

@implementation XDJSessionManager

+ (instancetype)sharedManager {
    static XDJSessionManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[XDJSessionManager alloc] initPrivate];
    });
    return instance;
}

- (instancetype)initPrivate {
    self = [super init];
    if (self) {
        _accessToken = [[NSUserDefaults standardUserDefaults] stringForKey:kXDJAccessTokenKey];
        _phone = [[NSUserDefaults standardUserDefaults] stringForKey:kXDJPhoneKey];
    }
    return self;
}

- (instancetype)init {
    [NSException raise:@"XindongrijiAppSingleton" format:@"Use +[XDJSessionManager sharedManager]."];
    return nil;
}

- (BOOL)hasLoginSession {
    return self.accessToken.length > 0;
}

- (void)updateToken:(NSString *)token phone:(NSString *)phone {
    self.accessToken = token;
    self.phone = phone;

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (token.length > 0) {
        [defaults setObject:token forKey:kXDJAccessTokenKey];
    } else {
        [defaults removeObjectForKey:kXDJAccessTokenKey];
    }

    if (phone.length > 0) {
        [defaults setObject:phone forKey:kXDJPhoneKey];
    } else {
        [defaults removeObjectForKey:kXDJPhoneKey];
    }

    [defaults synchronize];
}

- (void)clearSession {
    [self updateToken:nil phone:nil];
}

@end
