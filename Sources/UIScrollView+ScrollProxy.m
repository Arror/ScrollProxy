#import "ScrollProxy.h"
#import <objc/runtime.h>

void exchangeMethodImplementations(Class aClass, SEL original, SEL swizzled) {
    
    Method originalMethod = class_getInstanceMethod(aClass, original);
    Method swizzledMethod = class_getInstanceMethod(aClass, swizzled);
    
    BOOL didAddMethod = class_addMethod(aClass,
                                        original,
                                        method_getImplementation(swizzledMethod),
                                        method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        
        class_replaceMethod(aClass,
                            swizzled,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

@implementation UIScrollView (ScrollProxy)

const static NSString *kScrollProxyAssociatedKey = @"ScrollProxyAssociatedKey";

@dynamic proxy;

+ (void)initialize {
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        exchangeMethodImplementations([self class],
                                      @selector(setContentOffset:),
                                      @selector(swizzed_setContentOffset:));
    });
}

- (void)swizzed_setContentOffset:(CGPoint)contentOffset {
    
    [self.proxy offsetChangedOfScrollView:self];
    
    [self swizzed_setContentOffset:contentOffset];
}

- (void)setProxy:(ScrollProxy * _Nonnull)proxy {
    
    objc_setAssociatedObject(self, &kScrollProxyAssociatedKey, proxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (ScrollProxy *)proxy {
    
    ScrollProxy *p = (ScrollProxy *)objc_getAssociatedObject(self, &kScrollProxyAssociatedKey);
    
    if (!p) {
        
        [self setProxy:[[ScrollProxy alloc] init]];
    }
    
    return (ScrollProxy *)objc_getAssociatedObject(self, &kScrollProxyAssociatedKey);
}

@end
