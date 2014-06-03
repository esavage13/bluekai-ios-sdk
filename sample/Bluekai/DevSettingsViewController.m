#import "DevSettingsViewController.h"
#import "Bluekai.h"

@implementation DevSettingsViewController {
    BlueKai             *blueKaiSDK;
    NSArray             *paths;
    NSFileManager       *fileManager;
    NSMutableDictionary *configDict;
    NSString            *documentsDirectory;
    NSString            *plistFilePath;
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

@end
