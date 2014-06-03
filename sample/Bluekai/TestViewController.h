#import <UIKit/UIKit.h>

@class BlueKai;
@protocol BlueKaiOnDataPostedListener;

@interface TestViewController : UIViewController <UITextFieldDelegate, UIGestureRecognizerDelegate, UIWebViewDelegate, NSURLConnectionDelegate, UITabBarControllerDelegate>
{
    IBOutlet UITextField *keyTextfield;
    IBOutlet UITextField *valueTextfield;
    IBOutlet UIView      *view;
}

-(IBAction)cancelBtn:(id)sender;
-(IBAction)sendKeyValuePair:(id)sender;

@end