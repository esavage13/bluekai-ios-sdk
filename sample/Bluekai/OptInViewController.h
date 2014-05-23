#import <UIKit/UIKit.h>

@class BlueKai;
@protocol BlueKaiOnDataPostedListener;

@interface OptInViewController : UIViewController<UIWebViewDelegate,UITabBarControllerDelegate>
{
    BlueKai             *blueKaiSDK;
    UIAlertView         *alert;
    NSMutableDictionary *config_dict;

    IBOutlet UISegmentedControl *segment;
}

@end
