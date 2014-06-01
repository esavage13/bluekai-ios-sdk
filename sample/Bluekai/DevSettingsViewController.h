#import <UIKit/UIKit.h>

@interface DevSettingsViewController : UIViewController<UITextFieldDelegate>
{
    IBOutlet UISwitch    *devModeSwtich;
    IBOutlet UISwitch    *httpsSwtich;
    IBOutlet UITextField *siteIdTextfield;
    IBOutlet UITextField *idfaIdTextfield;
}

- (IBAction)devModeStateChanged:(id)sender;
- (IBAction)httpsModeStateChanged:(id)sender;

@end
