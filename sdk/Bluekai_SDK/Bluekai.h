#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol OnDataPostedListener <NSObject>
- (void)onDataPosted:(BOOL)status;
@end

@interface BlueKai : NSObject <UIWebViewDelegate, UIGestureRecognizerDelegate, NSURLConnectionDelegate> {
}

@property(nonatomic, weak) id <OnDataPostedListener> delegate;

- (id)initWithArgs:(BOOL)value withSiteId:(NSString *)siteID withAppVersion:(NSString *)version withView:(UIViewController *)view;

- (void)put:(NSString *)key withValue:(NSString *)value;

- (void)put:(NSDictionary *)dictionary;

- (void)showSettingsScreen;

- (void)resume;

- (void)setPreference:(BOOL)optIn;

- (void)setDevMode:(BOOL)mode;

- (void)setAppVersion:(NSString *)version;

- (void)setViewController:(UIViewController *)view;

- (void)setSiteId:(int)siteId;

@end
