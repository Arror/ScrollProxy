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
