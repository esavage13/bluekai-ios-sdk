#import "DevSettingsViewController.h"
#import "Bluekai.h"

@implementation DevSettingsViewController {
    BlueKai             *blueKaiSDK;
    NSArray             *paths;
    NSFileManager       *fileManager;
    NSMutableDictionary *configDict;
    NSString            *documentsDirectory;
    NSString            *plistFilePath;
    NSBundle            *mainBundle;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    if (self) {
        self.tabBarItem.title = @"Settings";
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view from its nib.
    

    NSError *error;
    paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    documentsDirectory = paths[0];
    fileManager = [NSFileManager defaultManager];
    plistFilePath = [documentsDirectory stringByAppendingPathComponent:@"Configurationfile.plist"];
    configDict = [[NSMutableDictionary alloc] initWithContentsOfFile:plistFilePath];
    BOOL success = [fileManager fileExistsAtPath:plistFilePath];

    if (!success) {
        // file does not exist, look into mainBundle
        NSString *defaultPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Configurationfile.plist"];
        [fileManager copyItemAtPath:defaultPath toPath:plistFilePath error:&error];
    }

    [devModeSwtich setOn:([configDict[@"devMode"] boolValue])];
    [httpsSwtich setOn:([configDict[@"useHttps"] boolValue])];

    siteIdTextfield.text = configDict[@"siteId"];
    idfaIdTextfield.text = configDict[@"idfaId"];

    blueKaiSDK = [[BlueKai alloc] initWithSiteId:siteIdTextfield.text
                                  withAppVersion:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]
                                        withIdfa:idfaIdTextfield.text
                                        withView:self
                                     withDevMode:[configDict[@"devMode"] boolValue]];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    configDict[@"siteId"] = siteIdTextfield.text;
    [configDict writeToFile:plistFilePath atomically:YES];
    configDict[@"idfaId"] = idfaIdTextfield.text;
    [configDict writeToFile:plistFilePath atomically:YES];
}

- (IBAction)devModeStateChanged:(id)sender {
    configDict[@"devMode"] = [sender isOn] ? @"YES" : @"NO";
    [configDict writeToFile:plistFilePath atomically:YES];
}

- (IBAction)httpsModeStateChanged:(id)sender {
    configDict[@"useHttps"] = [sender isOn] ? @"YES" : @"NO";
    [configDict writeToFile:plistFilePath atomically:YES];
}

- (IBAction)redirectButtonClicked:(id)sender {
    mainBundle = [NSBundle mainBundle];
    NSArray* cfBundleURLTypes = [mainBundle objectForInfoDictionaryKey:@"CFBundleURLTypes"];
    
    if ([cfBundleURLTypes isKindOfClass:[NSArray class]] && [cfBundleURLTypes lastObject]) {
        NSDictionary* cfBundleURLTypes0 = [cfBundleURLTypes objectAtIndex:0];
        if ([cfBundleURLTypes0 isKindOfClass:[NSDictionary class]]) {
            NSArray* cfBundleURLSchemes = [cfBundleURLTypes0 objectForKey:@"CFBundleURLSchemes"];
            if ([cfBundleURLSchemes isKindOfClass:[NSArray class]]) {
                NSString *url = [NSString stringWithFormat:@"http://mobileproxy.bluekai.com/redirect.html?__appUrlScheme=%@&someKey=someVal", cfBundleURLSchemes[0]]; // should return "BlueKaiSampleApp"
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
            }
        }
    }
}

@end
