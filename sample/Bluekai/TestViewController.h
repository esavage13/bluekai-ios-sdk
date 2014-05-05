#import <UIKit/UIKit.h>
#import "BlueKai.h"

@interface TestViewController : UIViewController <UITextFieldDelegate, UIGestureRecognizerDelegate, UIWebViewDelegate, NSURLConnectionDelegate, UITabBarControllerDelegate, OnDataPostedListener>
{
    BlueKai      *blueKaiSDK;
    NSDictionary *configDict;
    UIAlertView  *alert;
    
    IBOutlet UITextField *keyTextfield;
    IBOutlet UITextField *valueTextfield;
    IBOutlet UIView      *view;
}

-(IBAction)cancelBtn:(id)sender;
-(IBAction)sendKeyValuePair:(id)sender;

@end