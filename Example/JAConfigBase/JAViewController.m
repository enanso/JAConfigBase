//
//  JAViewController.m
//  JAConfigBase
//
//  Created by lanmemory@163.com on 05/11/2021.
//  Copyright (c) 2021 lanmemory@163.com. All rights reserved.
//

#import "JAViewController.h"
#import <JAConfigBase/JAConfig.h>
#import <CommonCrypto/CommonDigest.h>
#import <sys/sysctl.h>
#import <sys/syscall.h>
#import "JAConfigBase_Example-Swift.h"
//__attribute__((always_inline))强制内联，所有加了__attribute__((always_inline))的函数再被调用时不会被编译成函数调用而是直接扩展到调用函数体内
static int is_debugged() __attribute__((always_inline));


@interface JAViewController ()

@property (nonatomic, strong) UILabel *label;

@end

@implementation JAViewController

//检测是否处于debug状态
static int is_debugged(){
    
//    int sysctl(int *name, u_int namelen, void *old, size_t *oldlen, void *newp, size_t newlen);
//    name参数是一个用以指定查询的信息数组；
//    namelen用以指定name数组的元素个数；
//    old是用以函数返回的缓冲区；
//    oldlen用以指定oldp缓冲区长度；
//    newp和newlen在设置时使用；
//       当进程被调试器依附时，kinfo_proc结构下有一个kp_proc结构域，kp_proc的p_flag的被调试标识将被设置，即会进行类似如下的设置：
//       kinfo_proc. kp_proc. p_flag & P_TRACED
//      其中P_TRACED的定义如下：
//      #define P_TRACED        0x00000800  /* Debugged process being traced */
    
    int name[4] = {CTL_KERN,KERN_PROC,KERN_PROC_PID,getpid()};
    
    struct kinfo_proc Kproc;
    
    size_t kproc_size = sizeof(Kproc);
    
    memset((void*)&Kproc, 0, kproc_size);
    
    if (sysctl(name, 4, &Kproc, &kproc_size, NULL, 0) == -1) {
        perror("sysctl error \n ");
        exit(-1);
    }
    
    return (Kproc.kp_proc.p_flag & P_TRACED) ? 1 : 0;
}

- (UILabel *)label {
    if (!_label) {
        _label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.backgroundColor = UIColor.redColor;
        _label.textColor = UIColor.whiteColor;
        [self.view addSubview:_label];
        _label.center = self.view.center;
    }
    return _label;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.label.text = @"启动了";
}
- (void)testLog:(NSString *)log{
    //直接比较两个文件的内容
 
    
//    NSString *path = [[NSBundle mainBundle] bundlePath];
//    NSString *filePath1 = [path stringByAppendingPathComponent:@"aa.txt"];
//    NSString *filePath2 = [path stringByAppendingPathComponent:@"aa.txt"];
//
//
//    // MD5摘要比较
//    NSString *md5str1 = [self md5WithFilePath:filePath1];
//    NSString *md5str2 = [self md5WithFilePath:filePath2];
//    NSLog(@"==第1个==%@==第2个==%@",md5str1,md5str2);
//    if ([md5str1 isEqualToString:md5str2]){
//        NSLog(@"===相同==");
//    }else {
//        NSLog(@"===不相同==");
//    }
}
//检测embedded.mobileprovision是否被篡改，篡改则视为第二次签名，防止二次打包
// 校验值，可通过上一次打包获取
#define PROVISION_HASH @"w2vnN9zRdwo0Z0Q4amDuwM2DKhc="

static NSDictionary * rootDic=nil;

void checkSignatureMsg() {
    NSString *newPath=[[NSBundle mainBundle]resourcePath];
    if (!rootDic) {
        rootDic = [[NSDictionary alloc] initWithContentsOfFile:[newPath stringByAppendingString:@"/_CodeSignature/CodeResources"]];
    }
    NSDictionary*fileDic = [rootDic objectForKey:@"files2"];
    NSDictionary *infoDic = [fileDic objectForKey:@"embedded.mobileprovision"];
    NSData *tempData = [infoDic objectForKey:@"hash"];
    NSString *hashStr = [tempData base64EncodedStringWithOptions:0];
    if (![PROVISION_HASH isEqualToString:hashStr]){
        abort();//退出应用
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self testLog:@"你调试的时候点我了"];
//    if (is_debugged() == YES) {
//        self.label.text = @"正在调试";
//        [self testLog:@"你调试的时候点我了"];
//    }else {
//        self.label.text = @"没有调试";
//    }
////汇编调用系统方法，阻止对ptrace下符号断点
//#ifdef __arm64__
//    __asm__ volatile(
//         "mov x0,#31\n"//PT_DENY_ATTACH=31拒绝被附加
//         "mov x1,#0\n"//默认参数
//         "mov x2,#0\n"//默认参数
//         "mov x3,#0\n"//默认参数
//         "mov x16,#26\n"//这里26就是syscall调用SYS_ptrace系统方法的编号
//         "svc #0x80\n"//这条指令就是触发中断（系统级别的跳转）
//    );
//#endif
//#ifdef __arm__
//    __asm__ volatile(
//         "mov r0,#31\n"//PT_DENY_ATTACH=31拒绝被附加
//         "mov r1,#0\n"//默认参数
//         "mov r2,#0\n"//默认参数
//         "mov r3,#0\n"//默认参数
//         "mov r16,#26\n"//这里26就是syscall调用SYS_ptrace系统方法的编号
//         "svc #80\n"//这条指令就是触发中断（系统级别的跳转）
//    );
//#endif
}

//对文件进行加密处理（256字节）
- (NSString *)md5WithFilePath:(NSString *)path {
    
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:path];
    if ( handle== nil ) {
        return nil;
    }
    CC_MD5_CTX md5;
    CC_MD5_Init(&md5);
    BOOL done = NO;
    while ( !done ) {
        NSData* fileData = [handle readDataOfLength: 256 ];
        CC_MD5_Update(&md5, [fileData bytes], (CC_LONG)[fileData length]);
        if( [fileData length] == 0 ) done = YES;
    }
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &md5);
    NSString* s = [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                   digest[0], digest[1],
                   digest[2], digest[3],
                   digest[4], digest[5],
                   digest[6], digest[7],
                   digest[8], digest[9],
                   digest[10], digest[11],
                   digest[12], digest[13],
                   digest[14], digest[15]];
    return s;
}

@end
