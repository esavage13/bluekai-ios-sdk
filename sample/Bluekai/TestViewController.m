/*
 * Copyright 2013-present BlueKai, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "TestViewController.h"
#import "Bluekai.h"

@implementation TestViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    [obj_SDK put:@"void":@"initWithNibName"];
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tabBarItem.title=@"BlueKai";
    }
    return self;
}
							
- (void)viewDidLoad
{
    [super viewDidLoad];
    [obj_SDK put:@"void":@"viewDidLoad"];
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
    [obj_SDK put:@"void":@"appCameToForeGround"];
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
    NSDictionary *infoPList = [[NSBundle mainBundle] infoDictionary];
    NSString *appName = [infoPList objectForKey:@"CFBundleDisplayName"];
    
    NSDictionary *dictionary = @{
                                @"foo" : @"11",
                                @"bar" : @"22",
                                @"baz" : @"33",
                                @"displayName": appName,
                                };
    [obj_SDK put:dictionary];
    
    
}
-(void)viewWillAppear:(BOOL)animated
{
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appCameToForeGround) name:UIApplicationWillEnterForegroundNotification object:nil];
    self.tabBarController.delegate=self;
    [obj_SDK put:@"void":@"viewWillAppear"];
   // [obj_SDK release];
    //[config_dict release];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *plistPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Configurationfile.plist"];
    
    BOOL success = [fileManager fileExistsAtPath:plistPath];
    if(!success){
        //file does not exist. So look into mainBundle
        NSString *defaultPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Configurationfile.plist"];
        [fileManager copyItemAtPath:defaultPath toPath:plistPath error:&error];
    }
    config_dict=[[NSMutableDictionary alloc]initWithContentsOfFile:plistPath];
    

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
    [obj_SDK put:@"void":@"viewDidUnload"];
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
