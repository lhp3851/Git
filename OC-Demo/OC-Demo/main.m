//
//  main.m
//  OC-Demo
//
//  Created by sumian on 2019/1/18.
//  Copyright © 2019 lhp3851. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
//载入UIKit框架里的UIKit.h文件，其实只为一个UIApplication.h里的UIApplicationMain C语言函数
#import <UIKit/UIKit.h>

//载入AppDelegate.h文件，其实只为一个OC方法NSStringFromClass需要的参数
#import "AppDelegate.h"


@interface Student : NSObject{
    
@public
    int _no;
    int _age;
}
@end
@implementation Student

struct xx_cc_objc_class{
    Class isa;
};

int main(int argc, char * argv[]) {
    @autoreleasepool {
//        NSObject *object = [[NSObject alloc] init];
//        Class objectClass = [NSObject class];
//        Class objectMetaClass = object_getClass([NSObject class]);
//        struct xx_cc_objc_class *objectClass2 = (__bridge struct xx_cc_objc_class *)(objectClass);
//
//        NSLog(@"%p %p %p %p", object, objectClass, objectMetaClass,objectClass2);
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
    return 0;
}

@end



