

#import <UIKit/UIKit.h>
#import "BlueKai.h"
@interface OptInViewController : UIViewController<UIWebViewDelegate,UITabBarControllerDelegate,OnDataPostedListener>
{
    BlueKai *Obj_bluekai;
    NSMutableDictionary *config_dict;
    UIAlertView *alert;
    IBOutlet UISegmentedControl *segment;
}

@end
