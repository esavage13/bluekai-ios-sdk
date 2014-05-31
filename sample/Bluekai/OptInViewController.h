#import <UIKit/UIKit.h>

@class BlueKai;
@protocol BlueKaiOnDataPostedListener;

@interface OptInViewController : UIViewController<UIWebViewDelegate, UITabBarControllerDelegate>
{
    IBOutlet UISegmentedControl *segment;
}

@end
