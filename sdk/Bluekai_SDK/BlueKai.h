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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol BlueKaiOnDataPostedListener <NSObject>
- (void)onDataPosted:(BOOL)status;
@end

@interface BlueKai : NSObject <UIWebViewDelegate, UIGestureRecognizerDelegate, NSURLConnectionDelegate> {
}

/** Sets a delegate for callbacks from the BlueKai SDK
* Works in conjunction with the `onDataPosted` method
*/
@property (nonatomic, weak) id <BlueKaiOnDataPostedListener> delegate;

/** Sets iOS app version
*
* @param version, version of your iOS application
*/
@property (nonatomic) NSString *appVersion;

/** Sets development mode
*
* @param mode, turns on/off verbose logging with visual confirmation of params sent; defaults to "NO"
*/
@property (nonatomic) BOOL devMode;

/** Sets Apple IDFA id
* @param idfa, IDFA (Identifier for Advertising) id from Apple
*/
@property (nonatomic) NSString *idfa;

/** Sets user opt-in preference
*
* This replaces the deprecated "setPreference" method
*
* @param pref, sets user tracking preference; defaults to "YES"
*/
@property (nonatomic) BOOL optInPreference;

/** Sets BlueKai siteId
*
* @param id, contact your BlueKai rep for this id
*/
@property (nonatomic) NSString *siteId;

/** Sets HTTPS transfer protocol
*
* @param BOOL, sets HTTPS; defaults to "NO"
*/
@property (nonatomic) BOOL useHttps;

/** Sets ViewController
*
* @param ViewController, set the ViewController instance as view to get notification on the data posting status
*/
@property (nonatomic) UIViewController *viewController;

/** Init BlueKai SDK
*
* Create the instance for BlueKai SDK with required arguments
*
* @param siteId, contact your BlueKai rep for this id; required
* @param appVersion, version of your iOS application; required
* @param viewController, a view for the SDK to attach itself to for an invisible webView to call BlueKai tags with; required
* @param devMode, BOOL value to toggle on/off verbose logging; defaults to "NO"; optional
*/
- (id)initWithSiteId:(NSString *)siteID
      withAppVersion:(NSString *)version
            withView:(UIViewController *)view
         withDevMode:(BOOL)devMode;

/** Init BlueKai SDK with IDFA
*
* Create the instance for BlueKai SDK with required arguments and IDFA
*
* @param siteId, contact your BlueKai rep for this id; required
* @param appVersion, version of your iOS application; required
* @param idfa, IDFA (identifier for advertising) advertiser id from Apple, required
* @param viewController, a view for the SDK to attach itself to for an invisible webView to call BlueKai tags with; required
* @param devMode, BOOL value to toggle on/off verbose logging; defaults to "NO"; optional
*/
- (id)initWithSiteId:(NSString *)siteID
      withAppVersion:(NSString *)version
            withIdfa:(NSString *)idfa
            withView:(UIViewController *)view
         withDevMode:(BOOL)devMode;

/** Init BlueKai SDK (Deprecated)
*
* Deprecated; Use "initWithSiteId" instead
*
*/
- (id)initWithArgs:(BOOL)value
        withSiteId:(NSString *)siteID
    withAppVersion:(NSString *)version
          withView:(UIViewController *)view;

/** Sets URL params as a key/value pair
*
* @param key, URL param key; required
* @param value, URL param value; required
*/
- (void)updateWithKey:(NSString *)key
             andValue:(NSString *)value;

/** Sets URL params as a key/value pair
*
* Deprecated; use "updateWithKey:andValue" instead
*
* @param key, URL param key; required
* @param value, URL param value; required
*/
- (void)put:(NSString *)key
  withValue:(NSString *)value;

/** Sets URL params by using NSDictionary
*
* @param dictionary, key/value pairs to be constructed as URL params
*/
- (void)updateWithDictionary:(NSDictionary *)dictionary;

/** Sets URL params by using NSDictionary
*
* Deprecated; use "updateWithDictionary" instead
*
* @param dictionary, key/value pairs to be constructed as URL params
*/
- (void)put:(NSDictionary *)dictionary;

/** Displays BlueKai Optout screen
*
* Deprecated; use the "setOptInPreference" property instead
*
* Displays a view to allow user to optout of tracking by BlueKai
*
*/
- (void)showSettingsScreen;

/** Displays BlueKai Optout screen with option to set background color
*
* Deprecated; use the "setOptInPreference" property instead
*
* Same functionality as `showSettingsScreen` with option to set custom background color
*
* @param color, sets background color for settings UIViewController; defaults to `whiteColor`
*/
- (void)showSettingsScreenWithBackgroundColor:(UIColor *)color;

/** Resume BlueKai process
*
* Method to resume BlueKai process after calling application resumes or comes to foreground. To use in onResume() of the calling activity foreground.
*
*/
- (void)resume;

@end
