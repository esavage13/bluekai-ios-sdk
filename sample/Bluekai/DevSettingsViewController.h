#import <UIKit/UIKit.h>

@interface DevSettingsViewController : UIViewController<UITextFieldDelegate>
{
    IBOutlet UIButton    *dev_btn;
    IBOutlet UITextField *siteId_Txtfield;

    NSMutableDictionary    *config_dict;
    NSString               *plist_path;
    UITapGestureRecognizer *dev_tap;
}

@end
