#import "DevSettingsViewController.h"
#import "TestViewController.h"

@implementation DevSettingsViewController {
    NSMutableDictionary    *configDict;
    NSString               *plistPath;
    UITapGestureRecognizer *devTap;
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

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    plistPath = [paths[0] stringByAppendingPathComponent:@"Configurationfile.plist"];
    BOOL success = [fileManager fileExistsAtPath:plistPath];

    if (!success) {
        //file does not exist. So look into mainBundle
        NSString *defaultPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Configurationfile.plist"];
        [fileManager copyItemAtPath:defaultPath toPath:plistPath error:&error];
    }

    configDict = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];

    [devModeSwtich setOn:([configDict[@"devMode"] boolValue])];

    siteIdTextfield.text = configDict[@"siteId"];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"Configurationfile.plist"];
    configDict = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
    [configDict setValue:textField.text forKey:@"ServerURL"];
    NSLog(@"%@", configDict);
    [configDict writeToFile:filePath atomically:YES];
}

- (IBAction)devModeStateChanged:(id)sender {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"Configurationfile.plist"];
    configDict = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];

    if ([sender isOn]) {
        configDict[@"devMode"] = @"YES";
    } else {
        configDict[@"devMode"] = @"NO";
    }
    
    [configDict writeToFile:filePath atomically:YES];
}

@end
