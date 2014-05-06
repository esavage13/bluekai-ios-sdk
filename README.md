# Integrating the BlueKai SDK
## Download the BlueKai SDK for iOS

http://bluekai.github.io/bluekai-ios-sdk-static-libs.zip

## Obtain BlueKai site ID

For any demo projects a site id of `2` can be used.

But before you ship, be sure to contact your BlueKai account manager for your company site ID.

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

## Include BlueKai iOS SDK 

In `ViewController.h` file or the header file of your view, add 

```objectivec
@class BlueKai;
```

On the top of the corresponding implementaton `.m` file, add

```objectivec
#import 'BlueKai.h'
```

## Create Instance 

In `ViewController.h` file, define an instance of BlueKai SDK.

```objectivec
@interface ViewController : UIViewController
{
    BlueKai *blueKaiSdk;
}
```

## Initialize SDK 

In `viewDidLoad` method of `ViewController.h` file, initialize the
instance of the SDK by adding these lines. Set the view controller as
the delegate for BlueKai SDK. All the arguments are required.

  
```objectivec
blueKaiSdk = [[BlueKai alloc]initWithSiteId:@"2" withAppVersion:version withView:self withDevMode:YES]; 
```

The first argument (`initWithSiteId`) is site id, which you would get from BlueKai.

The second argument is app version (`withAppVersion`) and is not necessarily the
application version of the calling application. This is a value by
which BlueKai can uniquely indentify the application from which the
request originated. A suggested approach is to use "app name-version_number" format.

The third argument (`withView`) is a view to which the SDK can attach an invisible WebView to call BlueKai's tag. When
`devMode` is enabled, this view becomes visible to display values being passed to BlueKai's server for debugging.

The last argument (`withDevMode`) indicates whether you want developer mode. In this mode, a webview overlay will be displayed 
with response from the BluaKai server. You should turn this feature off in your production code.



## Passing a Value 

To pass a single key value pair to BlueKai SDK, use the below code

	[blueKaiSdk put:@"myKey" withValue:@"myValue"];
	

## Passing Multiple Values

To pass multiple of key value pairs to BlueKai SDK, create an NSDictionary with key/value pairs and use the below method

    [blueKaiSdk put:dictionary];

## Resuming Data Post 

The `resume()` method in BlueKai SDK should be invoked from the
calling view controller’s `appCameToForeground()` method. This should be
done in order to send out any queued data, which may not have been sent
because either the application was closed while data upload was in progress or due to network issues. Create a
notification in `viewDidLoad` method or wherever you deem fit.

```objectivec
[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appCameToForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
```

Define a method appCameToForeground and call `resume()`:

```objectivec
-(void)appCameToForeground
{
   [blueKaiSdk resume];
}
```

## Add Notification Support (Optional)

Declare the BlueKai SDK delegate in `ViewController.h`. This step is
optional and is needed only if you need a notification when data is posted
to BlueKai server.


```objectivec
@protocol OnDataPostedListener;

@interface ViewController : UIViewController
{
} 
```

Set `ViewController.h` as the delegate. You can place this code right after initializing SDK
  
```objectivec
blueKaiSdk = [[Bluekai alloc]initWithSiteId:@"2" withAppVersion:version withView:self withDevMode:NO]; 
blueKaiSdk.delegate = (id) self;
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
    [blueKaiSdk put:@"displayName" withValue:displayName];

```
# Public Methods 

| Definition        | Method           | 
| ------------- | ------------- | 
|  **[DEPRECATED]** Create the instance for Bluekai SDK with required arguments; use `initWithSiteId:(NSString *)siteId withAppVersion:(NSString *)version withView:(UIViewController *)view withDevMode(BOOL)value` instead | ~~- (id)initWithArgs:(BOOL)value withSiteId:(NSString *)siteID withAppVersion:(NSString *)version withView:(UIViewController *)view;~~
|  Create the instance for Bluekai SDK with required arguments | - (id)initWithSiteId:(NSString *)siteId withAppVersion:(NSString *)version withView:(UIViewController *)view withDevMode(BOOL)value  | 
|  Convenience constructor to initialize and get instance of BlueKai without arguments      | - (id)init  | 
|  Method to show BlueKai in-built opt-in or opt-out screen     | - (void)showSettingsScreen  | 
|  The same functionality as `showSettingsScreen` with ability to set custom background color | - (void)showSettingsScreenWithBackgroundColor:(UIColor *)color |
|  Method to resume BlueKai process after calling application resumes or comes to foreground. To use in onResume() of the calling activity foreground.     | - (void)resume  | 
|  **[DEPRECATED]** Method to set user opt-in or opt-out preference; use `setOptInPreference:(BOOL)OptIn` instead     | ~~- (void) setPreference:(BOOL)optIn~~  | 
|  Method to set user opt-in or opt-out preference           | - (void) setOptInPreference:(BOOL)OptIn
|  Set developer mode (YES or NO); provides verbose logging  | - (void) setDevMode:(BOOL)mode  | 
|  Set the calling application version number     | - (void) setAppVersion:(NSString *)version  | 
|  Set the ViewController instance as view to get notification on the data posting status     | - (void) setViewController:(UIViewController *)view  | 
|  Set BlueKai site id     | - (void)setSiteId:(int)siteId  | 
|  Use HTTPS transfer protocol (YES or NO) | - (void)useHttps:(BOOL)secured  |


# Updating the SDK 

Update, unless otherwise indicated, can be done by just copying over
the previous version. 
