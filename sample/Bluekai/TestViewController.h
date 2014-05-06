#import <UIKit/UIKit.h>

@class BlueKai;
@protocol OnDataPostedListener;

@interface TestViewController : UIViewController <UITextFieldDelegate, UIGestureRecognizerDelegate, UIWebViewDelegate, NSURLConnectionDelegate, UITabBarControllerDelegate>
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