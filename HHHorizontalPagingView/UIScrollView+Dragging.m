//
//  UIScrollView+Dragging.m
//  Demo
//
//  Created by weijingyun on 16/12/3.
//  Copyright © 2016年 weijingyun. All rights reserved.
//

#import "UIScrollView+Dragging.h"
#import <objc/runtime.h>

@implementation UIScrollView (Dragging)

+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
    
        Class clazz = [self class];
        SEL originalSelector = @selector(isDragging);
        SEL swizzledSelector = @selector(swizzled_isDragging);
        
        Method originalMethod = class_getInstanceMethod(clazz, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(clazz, swizzledSelector);
        
        BOOL success = class_addMethod(clazz, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
        if (success) {
            class_replaceMethod(clazz, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
        
    });
}

- (void)setDragging:(BOOL)dragging{
    objc_setAssociatedObject(self,@selector(isDragging),[NSNumber numberWithBool:dragging],OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)swizzled_isDragging{
    
    BOOL dragging = [objc_getAssociatedObject(self, _cmd) boolValue];
    return dragging || [self swizzled_isDragging];
}

@end
