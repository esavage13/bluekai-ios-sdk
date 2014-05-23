#import "OptInViewController.h"
#import "BlueKai.h"

@interface OptInViewController ()

@end

@implementation OptInViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tabBarItem.title = @"T&C";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated {
    NSArray *array = [self.view subviews];
    for (UIView *view in array) {
        if (![view isKindOfClass:[UIWebView class]]) {
            [view removeFromSuperview];
        }
    }

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appEnteredToForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    self.tabBarController.delegate = self;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *plistPath = [paths[0] stringByAppendingPathComponent:@"Configurationfile.plist"];

    BOOL success = [fileManager fileExistsAtPath:plistPath];

    if (!success) {
        // file does not exist; so look into mainBundle
        NSString *defaultPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Configurationfile.plist"];
        [fileManager copyItemAtPath:defaultPath toPath:plistPath error:&error];
    }

    config_dict = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    blueKaiSDK = [[BlueKai alloc] initWithSiteId:config_dict[@"siteId"]
                                  withAppVersion:[[NSBundle mainBundle]
                      objectForInfoDictionaryKey:@"CFBundleShortVersionString"]
                                        withView:self withDevMode:[config_dict[@"devMode"] boolValue]];
    blueKaiSDK.delegate = (id) self;
    
    NSLog(@"%@", blueKaiSDK);

    // adds a slight yellow tint to background
    [blueKaiSDK showSettingsScreenWithBackgroundColor:[UIColor colorWithRed:(246/255.0) green:(247/255.0) blue:(220/255.0) alpha:1.0]];
}

- (void)appEnteredToForeground {
    NSLog(@"Application opened");
    [blueKaiSDK resume];
}

- (void)onDataPosted:(BOOL)status {
    NSLog(@"**************** %hhd", status);
    NSString *alertMessage = status ? @"\nData sent successfully" : @"\nData could not be sent";
    
    alert = [[UIAlertView alloc] initWithTitle:nil message:alertMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];

    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(removeAlert:) userInfo:nil repeats:NO];
}

- (void)removeAlert:(id)sender {
    [alert dismissWithClickedButtonIndex:-1 animated:YES];
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    if (tabBarController.selectedIndex == 0 || tabBarController.selectedIndex == 1) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }

    return YES;
}

@end
