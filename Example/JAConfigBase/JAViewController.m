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
#include <pthread/pthread.h>
#import "JAConfigBase_Example-Swift.h"

static int  b  = 100;

//__attribute__((always_inline))强制内联，所有加了__attribute__((always_inline))的函数再被调用时不会被编译成函数调用而是直接扩展到调用函数体内
static int is_debugged() __attribute__((always_inline));


@interface JAViewController ()

@property (nonatomic, strong) UILabel *label;
@property(nonatomic, assign) pthread_rwlock_t lock;
@property(nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, strong) NSMutableArray *array;
@end

@implementation JAViewController
- (NSMutableArray *)array {
    if (!_array) {
        _array = [[NSMutableArray alloc] init];
    }
    return _array;
}
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
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}
- (void)loadView {
    [super loadView];
}
- (void)viewDidLoad{
    [super viewDidLoad];
    self.label.text = @"启动了";
//    [self GCDTest];
    int a = 10;
    void (^__weak block)(void) = ^{
         NSLog(@"block----%d",a);
     };
    
     void (^block1)(void) = ^{
         NSLog(@"block1");
     };
   
     NSLog(@"block-----%@",block);
     NSLog(@"block1----%@",block1);

}

- (void)testLog:(NSString *)log{
    //直接比较两个文件的内容
 
//    [self op];// 线程
    
    [self readsalf];///<安全读写
    
//    NSString *path = [[NSBundle mainBundle] bundlePath];
//    NSString *filePath1 = [path stringByAppendingPathComponent:@"aa.txt"];
//    NSString *filePath2 = [path stringByAppendingPathComponent:@"aa.txt"];
//    // MD5摘要比较
//    NSString *md5str1 = [self md5WithFilePath:filePath1];
//    NSString *md5str2 = [self md5WithFilePath:filePath2];
//    NSLog(@"==第1个==%@==第2个==%@",md5str1,md5str2);
//    if ([md5str1 isEqualToString:md5str2]){
//        NSLog(@"===相同==");
//    }else {
//        NSLog(@"===不相同==");
//    }
//    [self GCDTest];
}
- (void)GCDTest {
    
//    dispatch_sync(dispatch_get_main_queue(), ^(void){
//                NSLog(@"这里死锁了");
//            });
    //串行
//    dispatch_queue_t queue = dispatch_queue_create("com.demo.serialQueue", DISPATCH_QUEUE_SERIAL);
    
    // 主线程
//    dispatch_queue_t queue = dispatch_get_main_queue();
    // 全局队列
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    NSLog(@"1"); // 任务1
    dispatch_async(queue, ^{
        NSLog(@"2"); // 任务2
//        dispatch_sync(queue, ^{
//            NSLog(@"3"); // 任务3
//        });
        // performSelector（只在主线程中使用）
        [self performSelector:@selector(testMethod1) withObject:@"aaa" afterDelay:0.0];
        NSLog(@"4"); // 任务4
    });
    NSLog(@"5"); // 任务
}

- (void)testMethod1 {
    NSLog(@"3"); // 任务3
}

/**
 参考：https://blog.csdn.net/u011043997/article/details/86678771
 多线程：NSOperationQueue
 */
- (void)op{
    
    // 使用子类NSInvocationOperation（会在主线程调用，并没有创建新线程）
//    NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(invocationOperation) object:nil];
//    [op start];
    
      // 在其他线程中执行操作
//    [NSThread detachNewThreadSelector:@selector(invocationOperation) toTarget:self withObject:nil];
//    [NSThread detachNewThreadWithBlock:^{
//        NSLog(@"2---%@",[NSThread currentThread]);///<打印当前线程
//    }];
    
    
//    //使用子类NSBlockOperation（会在主线程调用，并没有创建新线程）
//    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
//        [self invocationOperation];
//    }];
//    // 添加额外操作
//    [op addExecutionBlock:^{
//        [self operation:1];
//    }];
//    [op addExecutionBlock:^{
//        [self operation:2];
//    }];
//    [op addExecutionBlock:^{
//        [self operation:3];
//    }];
//    [op addExecutionBlock:^{
//        [self operation:4];
//    }];
//    [op start];
    // NSOperationQueue使用
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    // 设置最大并发操作（默认-1，不限制并发执行）
    //    queue.maxConcurrentOperationCount = 1;// 串行队列
    queue.maxConcurrentOperationCount = 2;// 并发队列
    //    queue.maxConcurrentOperationCount = 8;// 并发队列
    NSInvocationOperation *op1 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(task1) object:nil];
    NSInvocationOperation *op2 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(task2) object:nil];
    NSBlockOperation *op3 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];///<模拟耗时操作
            NSLog(@"3---%@",[NSThread currentThread]);///<打印当前线程
        }
    }];
    NSBlockOperation *op4 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];///<模拟耗时操作
            NSLog(@"4---%@",[NSThread currentThread]);///<打印当前线程
        }
    }];
    op1.queuePriority = NSOperationQueuePriorityNormal;///<op1的优先级设置正常
    op4.queuePriority = NSOperationQueuePriorityHigh;///<op1的优先级设置较高
    [op3 addDependency:op2];//<让op3依赖于op2；先执行op2，再执行op3     
    [op2 addDependency:op1];//<让op2依赖于op1；先执行op1，再执行op2
    [queue addOperation:op1];
    [queue addOperation:op2];
    [queue addOperation:op3];
    [queue addOperation:op4];
    [op1 cancel];
}

- (void)invocationOperation {
    for (int i = 0; i < 2; i++) {
        [NSThread sleepForTimeInterval:2];///<模拟耗时操作
        NSLog(@"0---%@",[NSThread currentThread]);///<打印当前线程
    }
}
- (void)task1 {
    for (int i = 0; i < 2; i++) {
        [NSThread sleepForTimeInterval:2];///<模拟耗时操作
        NSLog(@"1---%@",[NSThread currentThread]);///<打印当前线程
    }
}
- (void)task2 {
    for (int i = 0; i < 2; i++) {
        [NSThread sleepForTimeInterval:2];///<模拟耗时操作
        NSLog(@"2---%@",[NSThread currentThread]);///<打印当前线程
    }
}

- (void)operation:(NSInteger)location {
    for (int i = 0; i < 2; i++) {
        [NSThread sleepForTimeInterval:2];///<模拟耗时操作
        NSLog(@"%ld---%@",location,[NSThread currentThread]);///<打印当前线程
    }
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

// 安全度读写
- (void)readsalf {
    
    // 参考：https://www.jianshu.com/p/3ba7975f3841
    // 底层读写锁
    pthread_rwlock_init(&_lock, NULL);
    dispatch_queue_t queue = dispatch_get_global_queue(0,0);
//    dispatch_queue_t queue = dispatch_queue_create("com.demo.CONCURRENTQueue", DISPATCH_QUEUE_CONCURRENT);
    for (NSInteger i = 0;i < 100; i++) {
        dispatch_async(queue,  ^{
            [self read:i];
        });

        dispatch_async(queue,  ^{
            [self write:i];
        });
    }

    //栅栏函数安全写（栅栏函数不能放在全局队列中）
    self.queue = dispatch_queue_create("rw_queue", DISPATCH_QUEUE_CONCURRENT);
    for (NSInteger i = 0;i < 100; i++) {
        dispatch_async(self.queue, ^{
            // 读
            if (i < self.array.count) {
                id value = self.array[i];
                NSLog(@"===dispatch_async安全读：%@",value);
            }
        });
        dispatch_barrier_async(self.queue, ^{
           // 写
           [self.array addObject:@(i)];
        });
    }
}

-(void)read:(NSInteger)index{
    pthread_rwlock_rdlock(&_lock);
    if (index < self.array.count) {
        //读操作
        id value = self.array[index];
        NSLog(@"===安全读取值：%@",value);
    }
    pthread_rwlock_unlock(&_lock);
}

-(void)write:(NSInteger)index{
    pthread_rwlock_wrlock(&_lock);
    //  写操作
    [self.array addObject:@(index)];
    pthread_rwlock_unlock(&_lock);
}

@end
