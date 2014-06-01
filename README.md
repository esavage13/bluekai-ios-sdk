## Integrating the BlueKai SDK
### Download the BlueKai SDK for iOS

http://bluekai.github.io/bluekai-ios-sdk-static-libs.zip

### Obtain BlueKai site ID

For any demo projects a site id of `2` can be used.

But before you ship, be sure to contact your BlueKai account manager for your company site ID.

### Add BlueKai SDK to Project

In XCode, drag the BlueKai_SDK folder into the project directory as shown. 

   ![Screenshot](http://bluekai.github.io/images/ios/image001.png)

When you do so you will get a prompt like the one below. Choose the
option shown in the screen. This is a suggested mechanism and you can
choose the option that fits your environment.

   ![Screenshot](http://bluekai.github.io/images/ios/image003.png)

### Add Dependencies 

Add `libsqlite3.0.dylib`, `SystemConfiguration.framework` to your
project. To do so, please follow these steps.

+ Select "Targets" from your project

    ![Screenshot](http://bluekai.github.io/images/ios/image005.png)
+ Select "Build Phases"
+ Click on "+" symbol in "Link Binary With Libraries" panel
+ Type "libsqli" in the search box
+ Select "`libsqlite3.dylib`" from the list
+ Click on the "Add" button
    
    ![Screenshot](http://bluekai.github.io/images/ios/image007.png)
+ Repeat this process to add SystemConfiguration.framework. Type "system" in the search box
+ Select "SystemConfiguration.framework" from the list
+ Click on the "Add" button

    ![Screenshot](http://bluekai.github.io/images/ios/image009.png)

### Include BlueKai iOS SDK 

In `ViewController.h` file or the header file of your view, add 

```objective-c
@class BlueKai;
```

On the top of the corresponding implementaton `.m` file, add

```objective-c
#import "BlueKai.h"
```

### Create Instance 

In `ViewController.h` file, define an instance of BlueKai SDK.

```objective-c
@interface ViewController : UIViewController
{
    BlueKai *blueKaiSdk;
}
```

### Initialize SDK 

In `viewDidLoad` method of `ViewController.h` file, initialize the
instance of the SDK by adding these lines. Set the view controller as
the delegate for BlueKai SDK. All the arguments are required.

  
```objective-c
blueKaiSdk = [[BlueKai alloc] initWithSiteId:@"2" withAppVersion:version withView:self withDevMode:YES]; 
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



### Passing a Value 

To pass a single key value pair to BlueKai SDK, use the below code

    [blueKaiSdk updateWithKey:@"myKey" andValue:@"myValue"];
  

### Passing Multiple Values

To pass multiple of key value pairs to BlueKai SDK, create an NSDictionary with key/value pairs and use the below method

    [blueKaiSdk updateWithDictionary:dictionary];

### Resuming Data Post 

The `resume()` method in BlueKai SDK should be invoked from the
calling view controller’s `appCameToForeground()` method. This should be
done in order to send out any queued data, which may not have been sent
because either the application was closed while data upload was in progress or due to network issues. Create a
notification in `viewDidLoad` method or wherever you deem fit.

```objective-c
[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appCameToForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
```

Define a method appCameToForeground and call `resume()`:

```objective-c
- (void)appCameToForeground
{
   [blueKaiSdk resume];
}
```

### Add Notification Support (Optional)

Declare the BlueKai SDK delegate in `ViewController.h`. This step is
optional and is needed only if you need a notification when data is posted
to BlueKai server.


```objective-c
@protocol BlueKaiOnDataPostedListener;

@interface ViewController : UIViewController
{
} 
```

Set `ViewController.h` as the delegate. You can place this code right after initializing SDK
  
```objective-c
blueKaiSdk = [[Bluekai alloc]initWithSiteId:@"2" withAppVersion:version withView:self withDevMode:NO]; 
blueKaiSdk.delegate = (id) <BlueKaiOnDataPostedListener> self;
```

To get notifications about the status of data posting, implement the
following delegate method in `ViewController.m`. 

```objective-c
- (void)onDataPosted:(BOOL)status {
    if (statu) {
        // ... react to data being posted to BlueKai...
    }
}
```

### Send displayName by Default (Recommended)

It's recommended that the display name of the application be sent in
addition to the site id: 

```objective-c
    NSDictionary *infoPList = [[NSBundle mainBundle] infoDictionary];
    NSString *displayName = [infoPList objectForKey:@"CFBundleDisplayName"];
    [blueKaiSdk updateWithKey:@"displayName" andValue:displayName];
```

## Public Methods

### Properties

Set a delegate for callbacks; works in conjunction with the `onDataPosted` method
```objective-c
@property (nonatomic, weak) id <BlueKaiOnDataPostedListener> delegate;
```

Set developer mode (YES or NO); provides verbose logging
```objective-c
@property (nonatomic) BOOL devMode;
```

Set the calling application version number
```objective-c
@property (nonatomic) NSString *appVersion;
```

Set the ViewController instance as view to get notification on the data posting status
```objective-c
@property (nonatomic) UIViewController *viewController;
```

Set BlueKai site id
```objective-c
@property (nonatomic) NSString *siteId;
```

Use HTTPS transfer protocol
```objective-c
@property (nonatomic) BOOL useHttps;
```


### Methods

Create the instance for Bluekai SDK with required arguments (with IDFA support).
```objective-c
- (id)initWithSiteId:(NSString *)siteId withAppVersion:(NSString *)version withIdfa:(NSString *)idfa withView:(UIViewController *)view withDevMode(BOOL)value
```

Create the instance for Bluekai SDK with required arguments (without IDFA support). This method is preferred if you do not have an Appple IDFA id.
```objective-c
- (id)initWithSiteId:(NSString *)siteId withAppVersion:(NSString *)version withView:(UIViewController *)view withDevMode(BOOL)value
```

**[DEPRECATED]**
Init a BlueKai object
```objective-c
- (id)initWithArgs:(BOOL)value withSiteId:(NSString *)siteID withAppVersion:(NSString *)version withView:(UIViewController *)view
```

Convenience constructor to initialize and get instance of BlueKai without arguments
```objective-c
- (id)init
```

**[DEPRECATED]**
Method to show BlueKai in-built opt-in or opt-out screen
```objective-c
- (void)showSettingsScreen
```

**[DEPRECATED]**
The same functionality as `showSettingsScreen` with ability to set custom background color
```objective-c
- (void)showSettingsScreenWithBackgroundColor:(UIColor *)color
```

Method to resume BlueKai process after calling application resumes or comes to foreground. To use in onResume() of the calling activity foreground.
```objective-c
- (void)resume
```

Method to set user opt-in or opt-out preference
```objective-c
- (void) setOptInPreference:(BOOL)OptIn
```

**[DEPRECATED]**
Method to set user opt-in or opt-out preference
```objective-c
- (void) setPreference:(BOOL)optIn
```

Set key/value strings and send them to BlueKai server
```objective-c
- (void)updateWithKey:(NSString *)key andValue:(NSString *)value
```

**[DEPRECATED]**
Set key/value strings and send them to BlueKai server
```objective-c
- (void)put:(NSString *)key withValue:(NSString *)value
```

Set key/value strings in a NSDictionary and send them to BlueKai server
```objective-c
- (void)updateWithDictionary:(NSDictionary *)dictionary
```

**[DEPRECATED]**
Set key/value strings in a NSDictionary and send them to BlueKai server
```objective-c
- (void)put:(NSDictionary *)dictionary
```

Allows your app to receive a callback from the BlueKai SDK when data has been posted to servers
```objective-c
- (void)onDataPosted:(BOOL)status;
```

## Updating the SDK 

Update, unless otherwise indicated, can be done by just copying over
the previous version. 
