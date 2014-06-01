#import <UIKit/UIKit.h>

@interface DevSettingsViewController : UIViewController<UITextFieldDelegate>
{
    IBOutlet UISwitch    *devModeSwtich;
    IBOutlet UITextField *siteIdTextfield;
}

- (IBAction)devModeStateChanged:(id)sender;

@end
