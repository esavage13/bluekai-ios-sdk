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

    [dev_btn setImage:[UIImage imageNamed:([configDict[@"devMode"] boolValue]) ? @"chk-1" : @"unchk-1"] forState:UIControlStateNormal];

    siteId_Txtfield.text = configDict[@"siteId"];
}

- (IBAction)changeDevMode:(id)sender {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"Configurationfile.plist"];
    configDict = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];

    UIButton *btn = (UIButton *) sender;
    UIImage *actual_image = btn.currentImage;
    NSData *present_image = UIImagePNGRepresentation(actual_image);
    NSData *compare_image = UIImagePNGRepresentation([UIImage imageNamed:@"unchk-1"]);

    if ([present_image isEqual:compare_image]) {
        [dev_btn setImage:[UIImage imageNamed:@"chk-1"] forState:UIControlStateNormal];
        //update the plist file
        configDict[@"devMode"] = @"YES";

    } else {
        [dev_btn setImage:[UIImage imageNamed:@"unchk-1"] forState:UIControlStateNormal];
        //update plist file

        [configDict setValue:@"NO" forKey:@"devMode"];
    }

    [configDict writeToFile:filePath atomically:YES];
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

@end
