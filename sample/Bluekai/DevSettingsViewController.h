#import <UIKit/UIKit.h>

@interface DevSettingsViewController : UIViewController<UITextFieldDelegate>
{
    IBOutlet UISwitch    *devModeSwtich;
    IBOutlet UISwitch    *httpsSwtich;
    IBOutlet UIButton    *redirectButton;
    IBOutlet UITextField *siteIdTextfield;
    IBOutlet UITextField *idfaIdTextfield;
}

- (IBAction)devModeStateChanged:(id)sender;
- (IBAction)httpsModeStateChanged:(id)sender;
- (IBAction)redirectButtonClicked:(id)sender;

@end
