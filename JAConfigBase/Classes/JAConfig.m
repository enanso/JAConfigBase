
#import "JAConfig.h"
#import <objc/runtime.h>

void swizzing(Class class, SEL originalSelector, SEL swizzledSelector){
    
    Method originalMethod = class_getClassMethod(class, originalSelector);
    Method swizzledMethod = class_getClassMethod(class, swizzledSelector);
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

//异或存取key
#define KEY 0xCA

//处理加密常量字符串“org.ay.demo.module”，阻止符号进入常量区
static NSString *BundleId(){
    unsigned char values[] = {
        (KEY ^ 'o'),
        (KEY ^ 'r'),
        (KEY ^ 'g'),
        (KEY ^ '.'),
        (KEY ^ 'a'),
        (KEY ^ 'y'),
        (KEY ^ '.'),
        (KEY ^ 'd'),
        (KEY ^ 'e'),
        (KEY ^ 'm'),
        (KEY ^ 'o'),
        (KEY ^ '.'),
        (KEY ^ 'm'),
        (KEY ^ 'o'),
        (KEY ^ 'd'),
        (KEY ^ 'u'),
        (KEY ^ 'l'),
        (KEY ^ 'e'),
        (KEY ^ '\0')//循环出口
    };
    unsigned char *p = values;
    while (((*p) ^=KEY) != '\0') p++;
    return [NSString stringWithUTF8String:(const char*)values];
}

//处理加密常量字符串“envCurrKey”，阻止符号进入常量区
static NSString *EnvCurrKey(){
    unsigned char values[] = {
        (KEY ^ 'e'),
        (KEY ^ 'n'),
        (KEY ^ 'v'),
        (KEY ^ 'C'),
        (KEY ^ 'u'),
        (KEY ^ 'r'),
        (KEY ^ 'r'),
        (KEY ^ 'K'),
        (KEY ^ 'e'),
        (KEY ^ 'y'),
        (KEY ^ '\0')//循环出口
    };
    unsigned char *p = values;
    while (((*p) ^=KEY) != '\0') p++;
    return [NSString stringWithUTF8String:(const char*)values];
}
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
        if (![bundleId isEqual:BundleId()]) {
            NSLog(@"===BundleId与当前项目不匹配:%@",bundleId);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.12* NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                //汇编调用系统退出应用程序的方法
                #ifdef __arm64__
                    __asm__ volatile(
                     "mov x0,#0\n"
                     "mov x16,#1\n"//这里"1"就是syscall调用SYS_exit系统方法的编号
                     "svc #0x80\n"//这条指令就是触发中断（系统级别的跳转）
                    );
                #endif
                #ifdef __arm__
                    __asm__ volatile(
                     "mov r0,#0\n"
                     "mov r16,#1\n"//这里"1"就是syscall调用SYS_exit系统方法的编号
                     "svc #80\n"//这条指令就是触发中断（系统级别的跳转）
                    );
                #endif
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
    NSString *baseURL = [[NSUserDefaults standardUserDefaults] objectForKey:EnvCurrKey()];
    if (baseURL) {
        return baseURL;
    }
#endif
    return @"https://www.baidu.com/";
}

@end
