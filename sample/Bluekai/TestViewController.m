#import "TestViewController.h"
#import "Bluekai.h"

@implementation TestViewController {
    BlueKai      *blueKaiSDK;
    NSDictionary *configDict;
    UIAlertView  *alert;
}

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

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appCameToForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
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
                                  withAppVersion:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]
                                        withIdfa:configDict[@"idfaId"]
                                        withView:self
                                     withDevMode:[configDict[@"devMode"] boolValue]];

    [blueKaiSDK setUseHttps:[configDict[@"useHttps"] boolValue]];
    blueKaiSDK.delegate = (id) self;
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    if (tabBarController.selectedIndex == 0 || tabBarController.selectedIndex == 1) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];

    }
    return YES;
}


- (void)appCameToForeground {
    [blueKaiSDK resume];
}

- (void)onDataPosted:(BOOL)status {
    if (blueKaiSDK.devMode) {
        NSString *msg = status ? @"\nData sent successfully" : @"\nData could not be sent";

        alert = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }

    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(removeAlert:) userInfo:nil repeats:NO];
}

- (void)removeAlert:(id)sender {
    [alert dismissWithClickedButtonIndex:-1 animated:YES];
}



#pragma mark - IBActions

- (IBAction)sendKeyValuePair:(id)sender {
    if (keyTextfield.text.length == 0) {
        if (blueKaiSDK.devMode) {
            alert = [[UIAlertView alloc] initWithTitle:@"Error message" message:@"Enter key" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    } else {
        if (valueTextfield.text.length == 0) {
            if (blueKaiSDK.devMode) {
                alert = [[UIAlertView alloc] initWithTitle:@"Error message" message:@"Enter value" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
        } else {
//            [blueKaiSDK put:keyTextfield.text withValue:valueTextfield.text]; // see "deprecate" warning
              // single key/val pairs
//            NSLog(@"##### SampleApp: sending via \"updateWithKey:andValue\"");
//            [blueKaiSDK updateWithKey:keyTextfield.text andValue:valueTextfield.text];
            // multiple key/val pairs as Dictionary
            NSLog(@"##### SampleApp: sending via \"updateWithDictionary\"");
            [blueKaiSDK updateWithDictionary:[[NSDictionary alloc] initWithObjectsAndKeys:valueTextfield.text,
                                                                                          keyTextfield.text,
                                                                                          @"anotherVal",
                                                                                          @"anotherKey", nil]];
        }
    }
}

- (IBAction)cancelBtn:(id)sender {
    keyTextfield.text = @"";
    valueTextfield.text = @"";
}
@end
