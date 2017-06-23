#import <UIKit/UIKit.h>

FOUNDATION_EXPORT double ScrollProxyVersionNumber;

FOUNDATION_EXPORT const unsigned char ScrollProxyVersionString[];


NS_ASSUME_NONNULL_BEGIN

@protocol OffsetChangedProtocol <NSObject>

- (void)offsetChangedOfScrollView:(UIScrollView *)scrollView;

@end

@interface ScrollProxy : NSProxy<OffsetChangedProtocol>

- (void)addResponder:(id<OffsetChangedProtocol> _Nullable)responder;

- (void)removeResponder:(id<OffsetChangedProtocol> _Nullable)responder;

- (void)removeAllResponders;

@end

@interface UIScrollView (ScrollProxy)

@property (nonatomic, strong, readonly) ScrollProxy *proxy;

@end

NS_ASSUME_NONNULL_END
