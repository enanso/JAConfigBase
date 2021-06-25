
#import "JAConfig.h"
#import <objc/runtime.h>

void swizzing(Class class, SEL originalSelector, SEL swizzledSelector){
    
    Method originalMethod = class_getClassMethod(class, originalSelector);
    Method swizzledMethod = class_getClassMethod(class, swizzledSelector);
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

NSString *const EnvCurrKey = @"EnvCurrKey";

NSString *const BundleId = @"org.cocoapods.demo.JAConfigBase-Example";

@implementation JAConfig

+ (NSURLSession *)qy_sessionWithConfiguration:(NSURLSessionConfiguration *)configuration
                                     delegate:(nullable id<NSURLSessionDelegate>)delegate
                                delegateQueue:(nullable NSOperationQueue *)queue{
    if (!configuration){
        configuration = [[NSURLSessionConfiguration alloc] init];
    }
    if ([self checkProxySetting]) {
        configuration.connectionProxyDictionary = @{};
    }
    return [self qy_sessionWithConfiguration:configuration delegate:delegate delegateQueue:queue];
}

+ (NSURLSession *)qy_sessionWithConfiguration:(NSURLSessionConfiguration *)configuration{
    if (configuration && [self checkProxySetting]){
        configuration.connectionProxyDictionary = @{};
    }
    return [self qy_sessionWithConfiguration:configuration];
}

//检测系统代理设置
+ (BOOL)checkProxySetting {
    NSDictionary *proxySettings = (__bridge NSDictionary *)(CFNetworkCopySystemProxySettings());
    NSArray *proxies = (__bridge NSArray *)(CFNetworkCopyProxiesForURL((__bridge CFURLRef _Nonnull)([NSURL URLWithString:@"https://www.baidu.com"]), (__bridge CFDictionaryRef _Nonnull)(proxySettings)));

    NSDictionary *settings = proxies[0];
//    NSLog(@"%@",[settings objectForKey:(NSString *)kCFProxyHostNameKey]);
//    NSLog(@"%@",[settings objectForKey:(NSString *)kCFProxyPortNumberKey]);
//    NSLog(@"%@",[settings objectForKey:(NSString *)kCFProxyTypeKey]);
    if ([[settings objectForKey:(NSString *)kCFProxyTypeKey] isEqualToString:@"kCFProxyTypeNone"]) {
        return NO;
    } else {
        //设置了代理
        exit(0);
        return YES;
    }
}

+(void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *bundleId = [self bundleID];
        if (![bundleId isEqual:BundleId]) {
            NSLog(@"===BundleId与当前项目不匹配:%@",bundleId);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.12* NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                exit(0);
            });
        }
        Class class = [NSURLSession class];
        swizzing(class, @selector(sessionWithConfiguration:), @selector(qy_sessionWithConfiguration:));

        swizzing(class, @selector(sessionWithConfiguration:delegate:delegateQueue:),
                 @selector(qy_sessionWithConfiguration:delegate:delegateQueue:));
    });
}
//获取BundleID
+(NSString*)bundleID{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
}
+ (instancetype)share {
    static JAConfig *config = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        config             = [[JAConfig alloc] init];
    });
    return config;
}

+(NSString *)baseUrl {
    
#ifdef DEBUG
    NSString *baseURL = [[NSUserDefaults standardUserDefaults] objectForKey:EnvCurrKey];
    if (baseURL) {
        return baseURL;
    }
#endif
    return @"https://www.baidu.com/";
}

@end
