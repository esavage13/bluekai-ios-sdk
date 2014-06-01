## v1.6.0 (05.09.2014)
-----
Enhancements and new features

### Bug fixes
- `Cancel` button now will hide BlueKai user opt-in preference screen properly
- `setOptInPreference` should default to `YES`

### Enhancements
- Namespace `onDataPostedListener` protocol to `BlueKaiOnDataPostedListener` to avoid clashing
- Documentation now encourages using `@class` forward reference to include the BlueKai iOS SDK instead of `#import`
- Add support for more informative `BlueKai` object via Objective-C's native `description` and `debugDescription` methods. `NSLog(@"%@", BlueKaiObject)` will now log:
        
    ```objectivec
    <BlueKai: 0x85c14a0, {
        appVersion = "4.2.0";
        devMode = YES;
        siteID = 2;
        useHTTPS = NO;
        view = "<TestViewController: 0x85ac200>";
    }>
    ```
- Transition all the setter/getter functions to Objective-C's native `@property` declarations
    - Free `setter` and `getter` functions
    - Do not impact existing functionalities
- Sample app
    - Enhance and update UI look & feel
    - Explose new UI controls from the UI

### New features
- Add a new init method to tag on IDFA id: `initWithSiteId:withAppVersion:withIdfa:withView:withDevMode`
- Add a new `@property` declaration to set an IDFA id
- Add `showSettingsScreenWithBackgroundColor` public method to allow setting background color for user preference screen, examples:
    - `[blueKaiSDK showSettingsScreenWithBackgroundColor:[UIColor whiteColor]]`
    - `[blueKaiSDK showSettingsScreenWithBackgroundColor:[UIColor colorWithRed:(246/255.0) green:(247/255.0) blue:(220/255.0) alpha:1.0]]`
- Add unit test coverage

### Deprecated
- The SDK no lonoger uses OpenUDID since the industry is moving towards [IDFA](http://blog.appsfire.com/udid-is-dead-openudid-is-deprecated-long-live-advertisingidentifier/)
- `- (void)put:(NSString *)key withValue:(NSString *)value` is deprecated in favor of `- (void)updateWithKey:(NSString *)key andValue:(NSString *)value`; no functional change
- `- (void)put:(NSDictionary *)dictionary` is deprecated in favor of `- (void)updateWithDictionary:(NSDictionary *)dictionary`; no functional change
- Show setting screen methods; use the `setOptInPreference` property to set the opt-in preference instead
    - `- (void)showSettingsScreen`
    - `- (void)showSettingsScreenWithBackgroundColor:(UIColor *)color`
- Use iOS native graphic elements to replace custom `png` images previously required
    

## v1.5.0 (05.05.2014)
-----
Major internal code updates and enhancements.

### Bug fixes
- All third party classes are now BlueKai namespaced ([bug #4](https://github.com/BlueKai/bluekai-ios-sdk/issues/4))

### Enhancements
- General code clean up, bringing SDK to use ARC and updated deprecated syntax
- All global variables are namespaced with `BlueKai_` prefix
- Upgrade `Reachability` class to the v3.5 (latest as of this release)
- More verbose inline documentation
- Update `README` documentation

### New features
- BlueKai SDK `NSLog`s can now be turned on/off via the `devMode` boolean
- Add ability to use `https` to tranfer data
- New mobile proxy endpoint

### Deprecated
- The `setPreference` method was ambigiously named and will be deprecated in favor of `setOptInPreference` method; no functionality change
- The `InitWithArgs` method is deprecated in favor of `InitWithSiteId:withAppVersion:withView:withDevMode`, no functionality change


## v1.0.1 (12.31.2013)
-----
No change should be required from v1.0.0 implementations.

### Enhancements
- Code cleanup
- When using the settings screen don't require ViewController
- Host static resource through GitHub
- New mobile proxy through GitHub


## v1.0.0 (08.20.2013)
-----
Initial SDK release.

- Initial release
- Pass individual hints or collections
