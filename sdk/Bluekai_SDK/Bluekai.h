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
@protocol OnDataPostedListener<NSObject>
-(void)onDataPosted:(BOOL)status;
@end
@interface BlueKai: NSObject<UIWebViewDelegate,UIGestureRecognizerDelegate,NSURLConnectionDelegate>{
}
@property (nonatomic,assign) id<OnDataPostedListener> delegate;
-(id)initWithArgs:(BOOL)value withSiteId:(NSString *)siteID withAppVersion:(NSString *)version withView:(UIViewController *)view;
-(void)put:(NSString *)key:(NSString *)value;
-(void)put:(NSDictionary *)dictionary;
-(void)showSettingsScreen;
-(void)resume;
-(void)setPreference:(BOOL)optIn;
-(void)setDevMode:(BOOL)mode;
-(void)setAppVersion:(NSString *)version;
-(void)setViewController:(UIViewController *)view;
-(void)setSiteId:(int)siteid;

@end
