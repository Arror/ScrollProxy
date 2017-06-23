#import "ScrollProxy.h"
#import <objc/runtime.h>

@implementation ScrollProxy {
    
    Protocol *_protocol;
    NSHashTable<id<OffsetChangedProtocol>> *_responders;
}

- (instancetype)init {
    
    _protocol = @protocol(OffsetChangedProtocol);
    _responders = [NSHashTable weakObjectsHashTable];
    
    return self;
}

- (void)addResponder:(id<OffsetChangedProtocol>)responder {
    
    [_responders addObject:responder];
}

- (void)removeResponder:(id<OffsetChangedProtocol>)responder {
    
    [_responders removeObject:responder];
}

- (void)removeAllResponders {
    
    [_responders removeAllObjects];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    
    NSMethodSignature *signature;
    
    struct objc_method_description theDescription = protocol_getMethodDescription(_protocol, sel, YES, YES);
    
    signature = [NSMethodSignature signatureWithObjCTypes:theDescription.types];
    
    return signature;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    
    NSString *selectorName = [NSString stringWithUTF8String:sel_getName(anInvocation.selector)];
    
    if (selectorName && ![selectorName isEqualToString:@""]) {
        for (id<OffsetChangedProtocol> object in _responders) {
            if ([object respondsToSelector:anInvocation.selector]) {
                [anInvocation invokeWithTarget:object];
            }
        }
    } else {
        [super forwardInvocation:anInvocation];
    }
}

@end


@implementation UIScrollView (ScrollProxy)

const static NSString *kScrollProxyAssociatedKey = @"ScrollProxyAssociatedKey";

@dynamic proxy;

+ (void)initialize {
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        Class aClass = [self class];
        
        SEL originalSEL = @selector(setContentOffset:);
        SEL swizzledSEL = @selector(swizzed_setContentOffset:);
        
        Method originalMethod = class_getInstanceMethod(aClass, originalSEL);
        Method swizzledMethod = class_getInstanceMethod(aClass, swizzledSEL);
        
        BOOL didAddMethod = class_addMethod(aClass,
                                            originalSEL,
                                            method_getImplementation(swizzledMethod),
                                            method_getTypeEncoding(swizzledMethod));
        
        if (didAddMethod) {
            
            class_replaceMethod(aClass,
                                swizzledSEL,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
        } else {
            
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
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

