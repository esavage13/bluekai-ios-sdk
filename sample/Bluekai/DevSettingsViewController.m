

#import "DevSettingsViewController.h"
#import "TestViewController.h"
@interface DevSettingsViewController ()

@end

@implementation DevSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
       self.tabBarItem.title=@"Settings";
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *plistPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Configurationfile.plist"];
   BOOL success = [fileManager fileExistsAtPath:plistPath];
    if(!success){
        //file does not exist. So look into mainBundle
        NSString *defaultPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Configurationfile.plist"];
      [fileManager copyItemAtPath:defaultPath toPath:plistPath error:&error];
    }
    config_dict=[[NSMutableDictionary alloc]initWithContentsOfFile:plistPath];
   if([[config_dict objectForKey:@"devMode"] boolValue])
     {
         [dev_btn setImage:[UIImage imageNamed:@"chk-1.png"] forState:UIControlStateNormal];
     }else{
         [dev_btn setImage:[UIImage imageNamed:@"unchk-1.png"] forState:UIControlStateNormal];
     }
   siteId_Txtfield.text=[config_dict objectForKey:@"siteId"];
   [config_dict release];

}
-(IBAction)changeDevMode:(id)sender
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"Configurationfile.plist"];
    config_dict=[[NSMutableDictionary alloc]initWithContentsOfFile:filePath];
        
    UIButton *btn=(UIButton *)sender;
    UIImage *actual_image=btn.currentImage;
    NSData *present_image = UIImagePNGRepresentation(actual_image);
    NSData *compare_image = UIImagePNGRepresentation([UIImage imageNamed:@"unchk-1.png"]);
    if([present_image isEqual:compare_image])
    {
        [dev_btn setImage:[UIImage imageNamed:@"chk-1.png"] forState:UIControlStateNormal];
        //update the plist file
        [config_dict setObject:@"YES" forKey:@"devMode"];
        
    }
    else
    {
        [dev_btn setImage:[UIImage imageNamed:@"unchk-1.png"] forState:UIControlStateNormal];
       //update plist file
        
        [config_dict setValue:@"NO" forKey:@"devMode"];
    }
    [config_dict writeToFile:filePath atomically:YES];
    [config_dict release];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{ NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"Configurationfile.plist"];
    config_dict=[[NSMutableDictionary alloc]initWithContentsOfFile:filePath];
    [config_dict setValue:textField.text forKey:@"ServerURL"];
    NSLog(@"%@",config_dict);
    [config_dict writeToFile:filePath atomically:YES];
    [config_dict release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
   // [config_dict release];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
