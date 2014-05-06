#import <UIKit/UIKit.h>

@class BlueKai;
@protocol OnDataPostedListener;

@interface OptInViewController : UIViewController<UIWebViewDelegate,UITabBarControllerDelegate>
{
    BlueKai *blueKaiSDK;
    NSMutableDictionary *config_dict;
    UIAlertView *alert;
    
    IBOutlet UISegmentedControl *segment;
}

@end
