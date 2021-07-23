//
//  main.m
//  JAConfigBase
//
//  Created by lanmemory@163.com on 05/11/2021.
//  Copyright (c) 2021 lanmemory@163.com. All rights reserved.
//

@import UIKit;
#import "JAAppDelegate.h"
#import <dlfcn.h>
#import <sys/types.h>

//阻止hackers使用调试器GDB、LLDB调试app

typedef int (*ptrace_ptr_t)(int _request, pid_t _pid, caddr_t _addr, int _data);
#if !defined(PT_DENY_ATTACH)
#define PT_DENY_ATTACH 31
#endif // !defined(PT_DENY_ATTACH)
void disable_gdb() {
    void* handle = dlopen(0, RTLD_GLOBAL | RTLD_NOW);
    ptrace_ptr_t ptrace_ptr = dlsym(handle, "ptrace");
    ptrace_ptr(PT_DENY_ATTACH, 0, 0, 0); dlclose(handle);
}

int main(int argc, char *argv[]) {
    // Don't interfere with Xcode debugging sessions.
#if !(DEBUG)
    disable_gdb();
#endif
    @autoreleasepool { return UIApplicationMain(argc, argv, nil, NSStringFromClass([JAAppDelegate class]));}
}

