#import <UIKit/UIKit.h>

@interface DevSettingsViewController : UIViewController<UITextFieldDelegate>
{
    IBOutlet UIButton    *dev_btn;
    IBOutlet UITextField *siteId_Txtfield;

    NSString *plist_path;
    UITapGestureRecognizer *dev_tap;
    NSMutableDictionary    *config_dict;
}

@end
