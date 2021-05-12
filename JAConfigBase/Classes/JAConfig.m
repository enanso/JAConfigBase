
#import "JAConfig.h"

NSString *const EnvCurrKey = @"EnvCurrKey";

NSString *const BundleId = @"org.cocoapods.demo.JAConfigBase-Example";

@implementation JAConfig

+(void)load {
    NSString *bundleId = [self bundleID];
    if (![bundleId isEqual:BundleId]) {
        NSLog(@"===BundleId与当前项目不匹配:%@",bundleId);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.12* NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            exit(0);
        });
    }
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
