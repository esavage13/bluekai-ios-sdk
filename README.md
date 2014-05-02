# Integrating the BlueKai SDK
## Download the BlueKai SDK for iOs

http://bluekai.github.io/bluekai-ios-sdk-static-libs.zip

## Obtain BlueKai site ID

For any demo projects a site id of "2" can be used. 

## Add BlueKai SDK to Project

In XCode, drag the BlueKai_SDK folder into the project directory as shown. 

   ![Screenshot](http://bluekai.github.io/images/ios/image001.png)

When you do so you will get a prompt like the one below. Choose the
option shown in the screen. This is a suggested mechanism and you can
choose the option that fits your environment.

   ![Screenshot](http://bluekai.github.io/images/ios/image003.png)

## Add Dependencies 

Add `libsqlite3.0.dylib`, `SystemConfiguration.framework` to your
project. To do so, please follow these steps.

+	Select "Targets" from your project

    ![Screenshot](http://bluekai.github.io/images/ios/image005.png)
+	Select "Build Phases"
+	Click on "+" symbol in "Link Binary With Libraries" panel
+	Type "libsqli" in the search box
+	Select "`libsqlite3.dylib`" from the list
+	Click on the "Add" button
    
    ![Screenshot](http://bluekai.github.io/images/ios/image007.png)
+ Repeat this process to add SystemConfiguration.framework. Type "system" in the search box
+	Select "SystemConfiguration.framework" from the list
+	Click on the "Add" button

    ![Screenshot](http://bluekai.github.io/images/ios/image009.png)

## Import SDK 

In `ViewController.h` file or the header file of your view, add 


    #import "BlueKai.h" 


## Create Instance 

In `ViewController.h` file, define an instance of BlueKai SDK.

```objectivec
@interface ViewController : UIViewController<OnDataPostedListener>
{
    BlueKai *obj_SDK;
}
```

## Initialize SDK 

In `viewDidLoad` method of `ViewController.h` file, initialize the
instance of the SDK by adding these lines. Set the view controller as
the delegate for BlueKai SDK. 

  
```objectivec
obj_SDK=[[BlueKai alloc]initWithArgs:NO withSiteId:@"2" withAppVersion:version withView:self]; 
```

The first argument indicates whether you want developer mode. In this mode, a webview overlay will be displayed 
with response from the BluaKai server. You should turn this feature off in your production code.
The second argument is site id, which you would get from BlueKai. The
third argument is app version and is not necessarily the
application version of the calling application. This is a value by
which BlueKai can uniquely indentify the application from which the
request originated. A suggested approach is to use "app
name-version_number" format. 



## Passing a Value 

To pass a single key value pair to BlueKai SDK, use the below code

	[obj_SDK put:@"Key":@"Value"];
	

## Passing Multiple Values 

To pass multiple of key value pairs to BlueKai SDK, create an NSDictionary with key/value pairs and use the below method

    [obj_SDK put:dictionary];

## Resuming Data Post 

The `resume()` method in BlueKai SDK should be invoked from the
calling view controller’s `appCameToForeGround()` method. This should be
done in order to send out any queued data, which may not have been sent
because either the application was closed while data upload was in progress or due to network issues. Create a
notification in viewDidLoad method or wherever you deem fit.

```objectivec
[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appCameToForeGround) name:UIApplicationWillEnterForegroundNotification object:nil];
```

Define a method appCameToForeGround and call `resume()`:

```objectivec
-(void)appCameToForeGround
{
   [obj_SDK resume];
}
```

## Add Notification Support (Optional)

Declare the BlueKai SDK delegate in `ViewController.h`. This step is
optional and is needed only if you need a notification when data is posted
to BlueKai server.


```objectivec
@interface ViewController : UIViewController<OnDataPostedListener>
{
} 
```

Set `ViewController.h` as the delegate. You can place this code right after initializing SDK
  
```objectivec
obj_SDK=[[Bluekai alloc]initWithArgs:NO withSiteId:@"2" withAppVersion:version withView:self]; 
obj_SDK.delegate=self;
```

To get notifications about the status of data posting, implement the
following delegate method in `ViewController.m`. 

```objectivec
-(void)onDataPosted:(BOOL)status
{
}
```

## Send displayName by Default (Recommended)

It's recommended that the display name of the application be sent in
addition to the site id: 

```objectivec
    NSDictionary *infoPList = [[NSBundle mainBundle] infoDictionary];
    NSString *displayName = [infoPList objectForKey:@"CFBundleDisplayName"];
    [obj_SDK put:@"displayName":displayName];

```
# Public Methods 

| Definition        | Method           | 
| ------------- | ------------- | 
|  Create the instance for Bluekai SDK with required arguments     | (id)initWithArgs:(BOOL)devMode withSiteId:(NSString *)siteId withAppVersion:(NSString *)version withView:(UIViewController *)view  | 
|  Convenience constructor to initialize and get instance of BlueKai without arguments      | (id)init  | 
|  Method to show BlueKai in-built opt-in or opt-out screen     | (void)showSettingsScreen  | 
|  Method to resume BlueKai process after calling application resumes or comes to foreground. To use in onResume() of the calling activity foreground.     | (void)resume  | 
|  Method to set user opt-in or opt-out preference     | (void)setPreference:(BOOL)optIn  | 
|  Set developer mode (YES or NO)     | (void)setdevMode:(BOOL)mode  | 
|  Set the calling application version number.     | (void)setAppVersion:(NSString *)version  | 
|  Set the ViewController instance as view to get notification on the data posting status     | (void)setViewController:(UIViewController *)view  | 
|  Set BlueKai site id     | (void)setSiteId:(int)siteid  | 


# Updating the SDK 

Update, unless otherwise indicated, can be done by just copying over
the previous version. 
