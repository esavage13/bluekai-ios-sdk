

#import "OptInViewController.h"

@interface OptInViewController ()

@end

@implementation OptInViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tabBarItem.title=@"T&C";
        
    }
    return self;
}
							
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}
-(void)viewWillAppear:(BOOL)animated
{
    NSArray *array=[self.view subviews];
    for (UIView *view in array) {
        if(![view isKindOfClass:[UIWebView class]])
        {
            [view removeFromSuperview];
        }
    }

     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnteredToForeGround) name:UIApplicationWillEnterForegroundNotification object:nil];
    self.tabBarController.delegate=self;
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
        Obj_bluekai=[[BlueKai alloc]initWithArgs:YES withSiteId:[config_dict objectForKey:@"siteId"] withAppVersion:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] withView:self];
    }
    else{
        Obj_bluekai=[[BlueKai alloc]initWithArgs:NO withSiteId:[config_dict objectForKey:@"siteId"] withAppVersion:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] withView:self];
    }

    Obj_bluekai.delegate=self;
    [Obj_bluekai showSettingsScreen];
}
-(void)appEnteredToForeGround
{
    NSLog(@"Application opened");
    [Obj_bluekai resume];
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

- (void)viewDidUnload
{
    [super viewDidUnload];
    [Obj_bluekai release];
    [config_dict release];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    if (tabBarController.selectedIndex==0 || tabBarController.selectedIndex==1) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    return YES;
}

@end
