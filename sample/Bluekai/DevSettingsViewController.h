

#import <UIKit/UIKit.h>

@interface DevSettingsViewController : UIViewController<UITextFieldDelegate>
{
   IBOutlet UILabel *devMode_lbl,*url_Lbl;
   IBOutlet UIImageView *dev_image;
   IBOutlet UITextField *siteId_Txtfield;
    UITapGestureRecognizer *dev_tap;
    IBOutlet UIButton *dev_btn;
    NSMutableDictionary *config_dict;
    NSString *plist_path;
}

@end
