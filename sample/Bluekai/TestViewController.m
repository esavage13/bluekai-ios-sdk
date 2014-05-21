#import "TestViewController.h"
#import "Bluekai.h"

@interface TestViewController ()
@end

@implementation TestViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    if (self) {
        //self.title = NSLocalizedString(@"BlueKai", @"BlueKai");
        self.tabBarItem.title = @"BlueKai";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)appCameToForeground {
    [blueKaiSDK resume];
}

- (void)onDataPosted:(BOOL)status {
    NSString *msg = status ? @"\n\nData sent successfully" : @"\n\nData could not be sent";

    alert = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];

    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(removeAlert:) userInfo:nil repeats:NO];
}

- (void)removeAlert:(id)sender {
    [alert dismissWithClickedButtonIndex:-1 animated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appCameToForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    self.tabBarController.delegate = self;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *plistPath = [paths[0] stringByAppendingPathComponent:@"Configurationfile.plist"];

    BOOL success = [fileManager fileExistsAtPath:plistPath];

    if (!success) {
        //file does not exist. So look into mainBundle
        NSString *defaultPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Configurationfile.plist"];
        [fileManager copyItemAtPath:defaultPath toPath:plistPath error:&error];
    }

    configDict = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];

//    if(![[configDict objectForKey:@"devMode"] boolValue])
//    {
//        NSArray *subviews=[self.view subviews];
//        for (UIView *view in subviews) {
//            if([view isKindOfClass:[UIWebView class]])
//            {
//                [view removeFromSuperview];
//            }
//            if([view isKindOfClass:[UIButton class]])
//            {
//                if(view.tag==10)
//                {
//                     [view removeFromSuperview];
//                }
//            }
//        }
//    }

    blueKaiSDK = [[BlueKai alloc] initWithSiteId:configDict[@"siteId"]
                                  withAppVersion:[[NSBundle mainBundle]
                                  objectForInfoDictionaryKey:@"CFBundleShortVersionString"]
                                  withView:self
                                  withDevMode:[configDict[@"devMode"] boolValue]];
    blueKaiSDK.delegate = (id) self;
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    if (tabBarController.selectedIndex == 0 || tabBarController.selectedIndex == 1) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];

    }
    return YES;
}



#pragma mark - IBActions

- (IBAction)sendKeyValuePair:(id)sender {
    if (keyTextfield.text.length == 0) {
        alert = [[UIAlertView alloc] initWithTitle:@"Error message" message:@"Enter key" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    } else {
        if (valueTextfield.text.length == 0) {
            alert = [[UIAlertView alloc] initWithTitle:@"Error message" message:@"Enter value" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        } else {
//            [blueKaiSDK put:keyTextfield.text withValue:valueTextfield.text]; // example for deprecate warning
            [blueKaiSDK updateWithKey:keyTextfield.text andValue:valueTextfield.text];
        }
    }
}

- (IBAction)cancelBtn:(id)sender {
    keyTextfield.text = @"";
    valueTextfield.text = @"";
}
@end
