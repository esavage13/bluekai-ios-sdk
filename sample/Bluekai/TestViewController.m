
#import "TestViewController.h"
#import "Bluekai.h"


@implementation TestViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //self.title = NSLocalizedString(@"BlueKai", @"BlueKai");
        self.tabBarItem.title=@"BlueKai";
    }
    return self;
}
							
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
-(IBAction)sendKeyValuePair:(id)sender
{
    if(key_Txtfld.text.length==0)
    {
        alert=[[UIAlertView alloc]initWithTitle:@"Error message" message:@"Enter key" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        alert.delegate=self;
        [alert show];
        [alert release];
    }
    else
    {
        if(value_Txtfld.text.length==0)
        {
           alert=[[UIAlertView alloc]initWithTitle:@"Error message" message:@"Enter value" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            alert.delegate=self;
            [alert show];
            [alert release];
        }
        else
        {
            [obj_SDK put:key_Txtfld.text :value_Txtfld.text];
        }
    }
}
-(void)appCameToForeGround
{
    NSLog(@"Application opened");
    [obj_SDK resume];
}
-(void)onDataPosted:(BOOL)status
{
    if(status)
    {
        alert=[[UIAlertView alloc]initWithTitle:nil message:@"\n\nData sent successfully" delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }
    else {
        alert=[[UIAlertView alloc]initWithTitle:nil message:@"\n\nData could not be sent" delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }
    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(removeAlert:) userInfo:nil repeats:NO];
}
-(void)removeAlert:(id)sender
{
    [alert dismissWithClickedButtonIndex:-1 animated:YES];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
-(IBAction)cancelBtn:(id)sender
{
    key_Txtfld.text=@"";
    value_Txtfld.text=@"";
}
-(void)viewWillAppear:(BOOL)animated
{
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appCameToForeGround) name:UIApplicationWillEnterForegroundNotification object:nil];
    self.tabBarController.delegate=self;
   // [obj_SDK release];
    //[config_dict release];
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
    
//    if(![[config_dict objectForKey:@"devMode"] boolValue])
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
    NSLog(@"%@",[config_dict objectForKey:@"devMode"]);
if([[config_dict objectForKey:@"devMode"]boolValue])
{
    obj_SDK=[[BlueKai alloc]initWithArgs:YES withSiteId:[config_dict objectForKey:@"siteId"] withAppVersion:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] withView:self];
}
else{
     obj_SDK=[[BlueKai alloc]initWithArgs:NO withSiteId:[config_dict objectForKey:@"siteId"] withAppVersion:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] withView:self];
}
    obj_SDK.delegate=self;
   // obj_SDK=[[Bluekai_SDK alloc]initWithBool:NO withSiteId:@"2" withAppVersion:@"1" withView:self];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [obj_SDK release];
    [config_dict release];
   
    // Release any retained subviews of the main view.
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    if (tabBarController.selectedIndex==0 || tabBarController.selectedIndex==1) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        
    }
    return YES;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
