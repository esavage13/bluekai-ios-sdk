

#import <UIKit/UIKit.h>
#import "BlueKai.h"
@interface TestViewController : UIViewController<UITextFieldDelegate,UIGestureRecognizerDelegate,UIWebViewDelegate,NSURLConnectionDelegate,UITabBarControllerDelegate,OnDataPostedListener>
{
    BlueKai *obj_SDK;
    IBOutlet UILabel *key_Lbl,*value_Lbl;
    IBOutlet UITextField *key_Txtfld,*value_Txtfld;
    IBOutlet UIButton *send_Btn,*Cancel_btn,*settings_btn;
    NSDictionary *config_dict;
    UIAlertView *alert;
}
-(IBAction)sendKeyValuePair:(id)sender;
-(IBAction)cancelBtn:(id)sender;

@end