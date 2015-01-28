#include <QuartzCore/QuartzCore.h>
#import "BlueKai.h"
#import "BlueKai_Protected.h"
#import "BlueKai_Reachability.h"
#import "BlueKai_SBJSON.h"

@implementation BlueKai {
    BOOL _alertShowBool,
         _webLoaded;

    unsigned long _urlLength,
        _numberOfRunningRequests;

    UIButton  *_cancelButton;
    UISwitch  *_optInSwitch;
    UIWebView *_webView;
}

static NSString *const MOBILE_PROXY_PARTIAL_URL = @"://mobileproxy.bluekai.com/";
static NSString *const OPTOUT_DEV_URL = @"http://mobileproxy.bluekai.com/";
static NSString *const BLUEKAI_DATA_URL = @"http://tags.bluekai.com/";
static NSString *const BLUEKAI_DATA_URL_SECURE = @"https://stags.bluekai.com/";
static NSString *const TERMS_AND_CONDITION_URL = @"http://www.bluekai.com/consumers_privacyguidelines.php";

#pragma mark - Public Methods

- (id)init {
    if (self = [super init]) {
        _appVersion = nil;
        _viewController = nil;
        _useDirectHTTPCalls = YES;
        _siteId = nil;
        _idfa = nil;
        _useHttps = NO;
        _devMode = NO;
        _optInPreference = YES;
        _userDefaults = [NSUserDefaults standardUserDefaults];
    }

    return self;
}

- (id)initWithSiteId:(NSString *)siteID withAppVersion:(NSString *)version withIdfa:(NSString *)idfa withView:(UIViewController *)view withDevMode:(BOOL)value {
    [self blueKaiLogger:_devMode withString:@"init siteId " withObject:siteID];
    [self blueKaiLogger:_devMode withString:@"init appVersion " withObject:version];
    [self blueKaiLogger:_devMode withString:@"init view " withObject:view];
    [self blueKaiLogger:_devMode withString:@"init DevMode " withObject:(value ? @"YES" : @"NO")];

    if (self = [super init]) {
        [self baseInitializaton];
        _appVersion = version;
        _idfa = idfa;
        _devMode = value;
        _siteId = siteID;
        _viewController = view;
        _cancelButton = nil;
        [self addWebView];
        
        if (![_userDefaults objectForKey:@"settings"]) {
            [_userDefaults setObject:@"NO" forKey:@"settings"];
        }

        if (![_userDefaults objectForKey:@"userIsOptIn"]) {
            [_userDefaults setObject:(_optInPreference ? @"YES" : @"NO") forKey:@"userIsOptIn"];
        }

        [self saveSettings:nil];

        

        // check the dictionary for previous values
        NSString *filePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
        NSString *fileName = @"user_data.bk";
        NSString *fileAtPath = [filePath stringByAppendingPathComponent:fileName];

        if (![[NSFileManager defaultManager] fileExistsAtPath:fileAtPath]) {
            [[NSFileManager defaultManager] createFileAtPath:fileAtPath contents:nil attributes:nil];
        }

        NSString *atmt_filePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
        NSString *atmt_fileName = @"attempts.bk";
        NSString *atmt_fileAtPath = [atmt_filePath stringByAppendingPathComponent:atmt_fileName];

        if (![[NSFileManager defaultManager] fileExistsAtPath:atmt_fileAtPath]) {
            [[NSFileManager defaultManager] createFileAtPath:atmt_fileAtPath contents:nil attributes:nil];
        }

        _keyValDict = [[NSMutableDictionary alloc] initWithDictionary:[self getKeyValueDictionary:[self readStringFromKeyValueFile]]];

        if ([[_keyValDict allKeys] count] > 1) {
            _numberOfRunningRequests = -1;
            BlueKai_Reachability *networkReachability = [BlueKai_Reachability reachabilityForInternetConnection];
            NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];

            if (networkStatus != NotReachable) {
                _webLoaded = YES;
                _webView.tag = 1;
                [self startDataUpload];
            } else {
                _alertShowBool = YES;
                [self webView:nil didFailLoadWithError:nil];
            }
        }
    }

    return self;
}

- (id)initWithSiteId:(NSString *)siteID withAppVersion:(NSString *)version withView:(UIViewController *)view withDevMode:(BOOL)devMode {
    return [self initWithSiteId:siteID withAppVersion:version withIdfa:nil withView:view withDevMode:devMode];
}

- (id)initDirectWithSiteId:(NSString *)siteID
      withAppVersion:(NSString *)version
            withIdfa:(NSString *)idfa
       withUserAgent:(NSString *)userAgent
         withDevMode:(BOOL)devMode {
    if (self = [super init]) {
        [self baseInitializaton];
        _appVersion = version;
        _idfa = idfa;
        _devMode = devMode;
        _siteId = siteID;
        _useDirectHTTPCalls = YES;
        _userAgent = userAgent;
        
        _cancelButton = nil;
        
        _webLoaded = NO;
        
        if (![_userDefaults objectForKey:@"settings"]) {
            [_userDefaults setObject:@"NO" forKey:@"settings"];
        }
        
        if (![_userDefaults objectForKey:@"userIsOptIn"]) {
            [_userDefaults setObject:(_optInPreference ? @"YES" : @"NO") forKey:@"userIsOptIn"];
        }
        
        [self saveSettings:nil];
        
        // check the dictionary for previous values
        NSString *filePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
        NSString *fileName = @"user_data.bk";
        NSString *fileAtPath = [filePath stringByAppendingPathComponent:fileName];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:fileAtPath]) {
            [[NSFileManager defaultManager] createFileAtPath:fileAtPath contents:nil attributes:nil];
        }
        
        NSString *atmt_filePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
        NSString *atmt_fileName = @"attempts.bk";
        NSString *atmt_fileAtPath = [atmt_filePath stringByAppendingPathComponent:atmt_fileName];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:atmt_fileAtPath]) {
            [[NSFileManager defaultManager] createFileAtPath:atmt_fileAtPath contents:nil attributes:nil];
        }
        
        _keyValDict = [[NSMutableDictionary alloc] initWithDictionary:[self getKeyValueDictionary:[self readStringFromKeyValueFile]]];
        
        if ([[_keyValDict allKeys] count] > 1) {
            _numberOfRunningRequests = -1;
            BlueKai_Reachability *networkReachability = [BlueKai_Reachability reachabilityForInternetConnection];
            NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
            
            if (networkStatus != NotReachable) {
                _webLoaded = YES;
                _webView.tag = 1;
                [self startDataUpload];
            } else {
                _alertShowBool = YES;
                [self webView:nil didFailLoadWithError:nil];
            }
        }
    }
    
    return self;

}

- (id)initDirectWithSiteId:(NSString *)siteID
      withAppVersion:(NSString *)version
            withIdfa:(NSString *)idfa
         withDevMode:(BOOL)devMode{
    return [self initDirectWithSiteId:siteID withAppVersion:version withIdfa:idfa withUserAgent:NULL withDevMode:devMode];
}

- (void)setViewController:(UIViewController *)view {
    [self blueKaiLogger:_devMode withString:@"setViewController" withObject:view];

    _viewController = view;

    if (_siteId) {
        _webView = nil;
        _cancelButton = nil;

        if (_webUrl) {
            [_webUrl replaceCharactersInRange:NSMakeRange(0, [_webUrl length]) withString:@""];
        } else {
            _webUrl = [[NSMutableString alloc] init];
        }

        [self addWebView];
        [self resume];
    }
}

- (void)resume {
    if (_webUrl) {
        [_webUrl replaceCharactersInRange:NSMakeRange(0, [_webUrl length]) withString:@""];
    } else {
        _webUrl = [[NSMutableString alloc] init];
    }

    _keyValDict = [[NSMutableDictionary alloc] initWithDictionary:[self getKeyValueDictionary:[self readStringFromKeyValueFile]]];

    if ([[_keyValDict allKeys] count] > 0) {
        _numberOfRunningRequests = -1;
        BlueKai_Reachability *networkReachability = [BlueKai_Reachability reachabilityForInternetConnection];
        NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];

        if (networkStatus != NotReachable) {
            _webView.tag = 1;
            [self startDataUpload];
        } else {
            [self webView:nil didFailLoadWithError:nil];
        }
    }
}

- (void)updateWithKey:(NSString *)key andValue:(NSString *)value {
    [self blueKaiLogger:_devMode withString:@"updateWithKeyValue:key" withObject:key];
    [self blueKaiLogger:_devMode withString:@"updateWithKeyValue:value" withObject:value];

    if (_webLoaded) {
        [_nonLoadkeyValDict setValue:value forKey:key];
    } else {
        if (_webUrl) {
            [_webUrl replaceCharactersInRange:NSMakeRange(0, [_webUrl length]) withString:@""];
        } else {
            _webUrl = [[NSMutableString alloc] init];
        }

        if (_keyValDict) {
            [_keyValDict removeAllObjects];
        } else {
            _keyValDict = [[NSMutableDictionary alloc] init];
        }

        [_keyValDict setValue:[value copy] forKey:[key copy]];
    }

    [self uploadIfNetworkIsAvailable];
}

- (void)updateWithDictionary:(NSDictionary *)dictionary {
    [self blueKaiLogger:_devMode withString:@"updateWithDictionary" withObject:dictionary];

    if (_webUrl) {
        [_webUrl replaceCharactersInRange:NSMakeRange(0, [_webUrl length]) withString:@""];
    } else {
        _webUrl = [[NSMutableString alloc] init];
    }

    if (_keyValDict) {
        [_keyValDict removeAllObjects];
    } else {
        _keyValDict = [[NSMutableDictionary alloc] init];
    }

    [_keyValDict setValuesForKeysWithDictionary:dictionary];

    [self uploadIfNetworkIsAvailable];
}

- (void)setOptInPreference:(BOOL)optIn {
    _optInPreference = optIn;

    [self blueKaiLogger:_devMode withString:@"setOptInPreference:OptIn" withObject:(_optInPreference ? @"YES" : @"NO")];

    [_userDefaults setObject:(_optInPreference ? @"YES" : @"NO") forKey:@"userIsOptIn"];

    [self saveSettings:nil];
    // TODO: Turn this back on when we can universally opt-out of BKSID
    //[self saveOptInPrefsOnServer];
}

- (void)showSettingsScreen {
    [self showSettingsScreenWithBackgroundColor:nil];
}

- (void)showSettingsScreenWithBackgroundColor:(UIColor *)backgroundColor {
    UIColor *bgColor = backgroundColor ? backgroundColor : [UIColor whiteColor];

    _viewController.view.hidden = NO;
    _viewController.view.backgroundColor = bgColor;

    _optInSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(238, 58, 0, 0)];
    [_optInSwitch setBackgroundColor:[UIColor whiteColor]];
    [_optInSwitch.layer setCornerRadius:16];
    [_optInSwitch setOn:_optInPreference];
    [_optInSwitch addTarget:self action:@selector(optInPreferenceChanged:) forControlEvents:UIControlEventValueChanged];
    [_viewController.view addSubview:_optInSwitch];

    UILabel *usrData_lbl = [[UILabel alloc] initWithFrame:CGRectMake(20, 48, 240, 50)];
    usrData_lbl.textColor = [UIColor blackColor];
    usrData_lbl.backgroundColor = [UIColor clearColor];
    usrData_lbl.textAlignment = NSTextAlignmentLeft;
    usrData_lbl.numberOfLines = 0;
    usrData_lbl.lineBreakMode = NSLineBreakByWordWrapping;
    usrData_lbl.font = [UIFont systemFontOfSize:14];
    usrData_lbl.text = @"Allow Bluekai to receive my data";
    [_viewController.view addSubview:usrData_lbl];

    UILabel *tclbl = [[UILabel alloc] initWithFrame:CGRectMake(18, 234, 280, 50)];
    tclbl.textColor = [UIColor blackColor];
    tclbl.backgroundColor = [UIColor clearColor];
    tclbl.textAlignment = NSTextAlignmentLeft;
    tclbl.numberOfLines = 3;
    tclbl.lineBreakMode = NSLineBreakByWordWrapping;
    tclbl.font = [UIFont systemFontOfSize:14];
    tclbl.text = @"The BlueKai privacy policy is available";
    [_viewController.view addSubview:tclbl];

    UIButton *hereButton = [UIButton buttonWithType:UIButtonTypeCustom];
    hereButton.frame = CGRectMake(256, 253, 50, 14);
    [hereButton setTitle:@"here" forState:UIControlStateNormal];
    hereButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [hereButton addTarget:self action:@selector(termsConditions:) forControlEvents:UIControlEventTouchUpInside];
    [hereButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [_viewController.view addSubview:hereButton];

    UIButton *savebtn = [UIButton buttonWithType:UIButtonTypeCustom];
    savebtn.frame = CGRectMake(75, 290, 80, 35);
    [savebtn setTitle:@"Save" forState:UIControlStateNormal];
    [savebtn.layer setBorderWidth:2.0f];
    [savebtn.layer setBorderColor:[[UIColor grayColor] CGColor]];
    [savebtn.layer setCornerRadius:5.0f];
    [savebtn setBackgroundColor:[UIColor whiteColor]];
    [savebtn addTarget:self action:@selector(saveSettings:) forControlEvents:UIControlEventTouchUpInside];
    [savebtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_viewController.view addSubview:savebtn];

    UIButton *cancelbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelbtn.frame = CGRectMake(175, 290, 80, 35);
    [cancelbtn setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelbtn.layer setBorderWidth:2.0f];
    [cancelbtn.layer setBorderColor:[[UIColor grayColor] CGColor]];
    [cancelbtn.layer setCornerRadius:5.0f];
    [cancelbtn setBackgroundColor:[UIColor whiteColor]];
    [cancelbtn addTarget:self action:@selector(Cancelbtn:) forControlEvents:UIControlEventTouchUpInside];
    [cancelbtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_viewController.view addSubview:cancelbtn];
    [_viewController.view addSubview:_webView];
    [_viewController.view addSubview:_cancelButton];
}


#pragma mark - Deprecated Methods

- (id)initWithArgs:(BOOL)value withSiteId:(NSString *)siteID withAppVersion:(NSString *)version withView:(UIViewController *)view {
    [self blueKaiLogger:_devMode withString:@"WARNING: [DEPRECATED] Please use the \"- (void) InitWithSiteId:withAppVersion:withView:withDevMode\" method instead" withObject:nil];
    return [self initWithSiteId:siteID withAppVersion:version withView:view withDevMode:value];
}

- (void)setPreference:(BOOL)optIn {
    [self blueKaiLogger:_devMode withString:@"WARNING: [DEPRECATED] Please use the \"- (void) setOptInPreference\" method instead" withObject:nil];
    [self setOptInPreference:optIn];
}

- (void)put:(NSString *)key withValue:(NSString *)value {
    [self blueKaiLogger:_devMode withString:@"WARNING: [DEPRECATED] Please use the \"- (void) updateWithKey:andValue\" method instead" withObject:nil];
    [self updateWithKey:key andValue:value];
}

- (void)put:(NSDictionary *)dictionary {
    [self blueKaiLogger:_devMode withString:@"WARNING: [DEPRECATED] Please use the \"- (void) updateWithDictionary\" method instead" withObject:nil];
    [self updateWithDictionary:dictionary];
}


#pragma mark - Objective-C Method overrides

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p, %@>",
                                      [self class],
                                      self,
                                      @{
                                          @"appVersion": _appVersion,
                                          @"devMode": _devMode ? @"YES" : @"NO",
                                          @"idfa": _idfa,
                                          @"optInPreference": _optInPreference ? @"YES" : @"NO",
                                          @"siteID": _siteId,
                                          @"useHTTPS": _useHttps ? @"YES" : @"NO",
                                          @"view": _viewController
                                      }];
}

- (NSString *)debugDescription {
    return [self description];
}


#pragma mark - IBActions

- (IBAction)termsConditions:(id)sender {
    NSURL *hereUrl = [[NSURL alloc] initWithString:TERMS_AND_CONDITION_URL];
    //Create the URL object

    [[UIApplication sharedApplication] openURL:hereUrl];
    //Launch Safari with the URL you created
}

- (IBAction)Cancelbtn:(id)sender {
    [self blueKaiLogger:_devMode withString:@"cancel opt-in view" withObject:nil];
    _viewController.view.hidden = YES;
}

- (IBAction)Cancel:(id)sender {
    _webView.hidden = YES;
    _cancelButton.hidden = YES;
}

- (IBAction)saveSettings:(id)sender {
    NSString *userDataValue = [_userDefaults objectForKey:@"userIsOptIn"];
    [_userDefaults setObject:userDataValue forKey:@"settings"];

    // TODO: Turn this back on when we can universally opt-out of BKSID
    // [self saveOptInPrefsOnServer];

    // TODO: Remove when BKSID opt-out is implemented; may need to be deprecated
    id <BlueKaiOnDataPostedListener> localDelegate = _delegate;

    if ([localDelegate respondsToSelector:@selector(onDataPosted:)]) {
        [localDelegate onDataPosted:FALSE];
    }
    // end TODO
}


#pragma mark - Private Methods

- (void)writeStringToKeyValueFile:(NSString *)aString {
    // Build the path, and create if needed.
    NSString *filePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    NSString *fileName = @"user_data.bk";
    NSString *fileAtPath = [filePath stringByAppendingPathComponent:fileName];

    if (![[NSFileManager defaultManager] fileExistsAtPath:fileAtPath]) {
        [[NSFileManager defaultManager] createFileAtPath:fileAtPath contents:nil attributes:nil];
    } else {
        [[NSFileManager defaultManager] removeItemAtPath:fileAtPath error:nil];
    }
    // The main act...
    [[aString dataUsingEncoding:NSUTF8StringEncoding] writeToFile:fileAtPath atomically:NO];
}

- (NSString *)readStringFromKeyValueFile {
    // Build the path...
    NSString *filePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    NSString *fileName = @"user_data.bk";
    NSString *fileAtPath = [filePath stringByAppendingPathComponent:fileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:fileAtPath]) {
        [[NSFileManager defaultManager] createFileAtPath:fileAtPath contents:nil attributes:nil];
        return [NSString string];
    } else {
        return [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:fileAtPath] encoding:NSUTF8StringEncoding];
    }
    // The main act...
}

- (NSString *)getKeyValueJSON:(NSMutableDictionary *)keyValues {
    @try {
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithDictionary:keyValues];
        BlueKai_SBJsonWriter *sb = [[BlueKai_SBJsonWriter alloc] init];
        NSString *jsonString = [sb stringWithObject:dictionary];

        return jsonString;
    }
    @catch (NSException *ex) {
        [self blueKaiLogger:_devMode withString:@"Exception is " withObject:ex];

        return nil;
    }
}

- (NSDictionary *)getKeyValueDictionary:(NSString *)jsonString {
    BlueKai_SBJSON *sparser = [[BlueKai_SBJSON alloc] init];
    NSDictionary *realdata = (NSDictionary *) [sparser objectWithString:jsonString error:nil];
    return realdata;
}

- (void)writeStringToAttemptsFile:(NSString *)aString {
    // Build the path, and create if needed.
    NSString *filePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    NSString *fileName = @"attempts.bk";
    NSString *fileAtPath = [filePath stringByAppendingPathComponent:fileName];

    if (![[NSFileManager defaultManager] fileExistsAtPath:fileAtPath]) {
        [[NSFileManager defaultManager] createFileAtPath:fileAtPath contents:nil attributes:nil];
    } else {
        [[NSFileManager defaultManager] removeItemAtPath:fileAtPath error:nil];
    }

    // The main act...
    [[aString dataUsingEncoding:NSUTF8StringEncoding] writeToFile:fileAtPath atomically:NO];
}

- (NSString *)readStringFromAttemptsFile {
    // Build the path...
    NSString *filePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    NSString *fileName = @"attempts.bk";
    NSString *fileAtPath = [filePath stringByAppendingPathComponent:fileName];

    // The main act...
    return [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:fileAtPath] encoding:NSUTF8StringEncoding];
}

- (NSString *)getAttemptsJSON:(NSMutableDictionary *)keyValues {
    [self blueKaiLogger:_devMode withString:@"getAttemptsJSON: " withObject:keyValues];

    @try {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:keyValues];
        BlueKai_SBJsonWriter *sb = [[BlueKai_SBJsonWriter alloc] init];
        NSString *jsonString = [sb stringWithObject:dict];
        return jsonString;
    }

    @catch (NSException *ex) {
        [self blueKaiLogger:_devMode withString:@"Exception is " withObject:ex];
        return nil;
    }
}

- (NSDictionary *)getAttemptsDictionary:(NSString *)jsonString {
    [self blueKaiLogger:_devMode withString:@"getAttemptsDictionary" withObject:jsonString];
    BlueKai_SBJSON *sparser = [[BlueKai_SBJSON alloc] init];
    NSDictionary *realData = (NSDictionary *) [sparser objectWithString:jsonString error:nil];
    return realData;
}

- (void)saveOptInPrefsOnServer {
    _numberOfRunningRequests = -1;
    BlueKai_Reachability *networkReachability = [BlueKai_Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];

    if (networkStatus != NotReachable) {
        UIWebView *optInWebView = [[UIWebView alloc] init];
        // use mobileproxy for development
        NSString *server = _devMode ? OPTOUT_DEV_URL : BLUEKAI_DATA_URL;
        NSString *urlPath = [[_userDefaults objectForKey:@"userIsOptIn"] isEqualToString:@"YES"] ? @"clear_ignore" : @"set_ignore";
        NSMutableString *url = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"%@%@", server, urlPath]];

        [self blueKaiLogger:_devMode withString:@"opt-in preference is set to" withObject:[_userDefaults objectForKey:@"userIsOptIn"]];

        [_viewController.view addSubview:optInWebView];
        [optInWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    } else {
        [self webView:nil didFailLoadWithError:nil];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self blueKaiLogger:_devMode withString:@"Web View Error" withObject:error];

    // to avoid the "Weak receiver may be unpredictably null in ARC mode" warning
    id <BlueKaiOnDataPostedListener> localDelegate = _delegate;

    if ([localDelegate respondsToSelector:@selector(onDataPosted:)]) {
        [localDelegate onDataPosted:FALSE];
    }

    if (_numberOfRunningRequests != 0) {
        _numberOfRunningRequests = 0;

        for (int i = 0; i < [[_keyValDict allKeys] count]; i++) {
            if (![_remainkeyValDict valueForKey:[_keyValDict allKeys][i]]) {
                NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithDictionary:[self getKeyValueDictionary:[self readStringFromKeyValueFile]]];
                NSMutableDictionary *atmt_dictionary = [[NSMutableDictionary alloc] initWithDictionary:[self getAttemptsDictionary:[self readStringFromAttemptsFile]]];
                int attempts = [atmt_dictionary[[_keyValDict allKeys][i]] intValue];

                if (attempts == 0) {
                    dictionary[[_keyValDict allKeys][i]] = [_keyValDict valueForKey:[_keyValDict allKeys][i]];
                    atmt_dictionary[[_keyValDict allKeys][i]] = @"1";
                } else {
                    if (attempts < 5) {
                        [atmt_dictionary removeObjectForKey:[_keyValDict allKeys][i]];
                        atmt_dictionary[[_keyValDict allKeys][i]] = [NSString stringWithFormat:@"%d", attempts + 1];
                    } else {
                        [dictionary removeObjectForKey:[_keyValDict allKeys][i]];
                        [atmt_dictionary removeObjectForKey:[_keyValDict allKeys][i]];
                    }
                }

                [self writeStringToKeyValueFile:[self getKeyValueJSON:dictionary]];
                [self writeStringToAttemptsFile:[self getAttemptsJSON:atmt_dictionary]];
            }
        }

        _webLoaded = NO;

        if (_remainkeyValDict != NULL || _nonLoadkeyValDict != NULL) {
            if ([_remainkeyValDict count] != 0 || [_nonLoadkeyValDict count] != 0) {
                [self loadAnotherRequest];
            }
        }
    }
}

- (void)updateWebview:(NSString *)url {
    if (!_useDirectHTTPCalls) {
        [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    // if "_numberOfRunningRequests" is not -1, increment by 1; otherwise (0 or -1) set it back to 1
    _numberOfRunningRequests = _numberOfRunningRequests != -1 ? _numberOfRunningRequests + 1 : 1;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    _numberOfRunningRequests = _numberOfRunningRequests - 1;
    // to avoid the "Weak receiver may be unpredictably null in ARC mode" warning
    id <BlueKaiOnDataPostedListener> localDelegate = _delegate;


    if (_numberOfRunningRequests == 0) {
        if (!_alertShowBool) {
            if (_webView.tag == 1) {
                //Delete the key and value pairs from database after sent to server.
                for (int k = 0; k < [_keyValDict count]; k++) {
                    if ([_remainkeyValDict valueForKey:[_keyValDict allKeys][k]] != NULL) {
                        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithDictionary:[self getKeyValueDictionary:[self readStringFromKeyValueFile]]];
                        NSMutableDictionary *atmt_dictionary = [[NSMutableDictionary alloc] initWithDictionary:[self getAttemptsDictionary:[self readStringFromAttemptsFile]]];
                        int attempts = [atmt_dictionary[[_keyValDict allKeys][k]] intValue];

                        if (attempts != 0) {
                            [dictionary removeObjectForKey:[_keyValDict allKeys][k]];
                            [atmt_dictionary removeObjectForKey:[_keyValDict allKeys][k]];
                            [self writeStringToKeyValueFile:[self getKeyValueJSON:dictionary]];
                            [self writeStringToAttemptsFile:[self getAttemptsJSON:atmt_dictionary]];
                        }
                    }
                }
            }

            if (_devMode) {
                _webView.hidden = NO;
                _cancelButton.hidden = NO;
            }

            _webLoaded = NO;

            if ([localDelegate respondsToSelector:@selector(onDataPosted:)]) {
                [localDelegate onDataPosted:TRUE];
            }

            [self blueKaiLogger:_devMode withString:@"URL loaded" withObject:webView.request.URL];
            _alertShowBool = YES;

            if (_remainkeyValDict || _nonLoadkeyValDict) {
                if ([_remainkeyValDict count] != 0 || [_nonLoadkeyValDict count] != 0) {
                    [self loadAnotherRequest];
                }
            }

            NSArray *webViews = [_viewController.view subviews];
            int webCount = 0;
            int buttonCount = 0;

            for (UIView *view in webViews) {
                if ([view isKindOfClass:[UIWebView class]]) {
                    webCount++;
                } else {
                    if ([view isKindOfClass:[UIButton class]]) {
                        if (view.tag == 10) {
                            buttonCount++;
                        }
                    }
                }
            }

            if (webCount > 1) {
                for (UIView *view in webViews) {
                    if ([view isKindOfClass:[UIWebView class]]) {
                        if (webCount >= 2) {
                            [view removeFromSuperview];
                            webCount--;
                        } else {
                            view.hidden = YES;
                        }
                    } else {
                        if ([view isKindOfClass:[UIButton class]]) {
                            if (view.tag == 10) {
                                if (buttonCount >= 2) {
                                    [view removeFromSuperview];
                                    buttonCount--;
                                } else {
                                    view.hidden = YES;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

- (void)loadAnotherRequest {
    [self blueKaiLogger:_devMode withString:@"loadAnotherRequest" withObject:nil];

    if ([_remainkeyValDict count] == 0) {
        if ([_nonLoadkeyValDict count] != 0) {
            
            if (!_useDirectHTTPCalls) {
                [self addWebView];
            }
            

            if (_keyValDict) {
                [_keyValDict removeAllObjects];
            } else {
                _keyValDict = [[NSMutableDictionary alloc] init];
            }

            _numberOfRunningRequests = -1;

            if (_webUrl) {
                [_webUrl replaceCharactersInRange:NSMakeRange(0, [_webUrl length]) withString:@""];
            } else {
                _webUrl = [[NSMutableString alloc] init];
            }

            //Code to send the multiple values for every request.
            NSUInteger keysCount = [[_nonLoadkeyValDict allKeys] count];

            for (int i = 0; i < keysCount; i++) {
                NSString *key = [NSString stringWithFormat:@"%@", [_nonLoadkeyValDict allKeys][i]];
                NSString *value = [NSString stringWithFormat:@"%@", _nonLoadkeyValDict[[_nonLoadkeyValDict allKeys][i]]];

                if ((_urlLength + key.length + value.length + 2) <= 255) {
                    [_keyValDict setValue:[_nonLoadkeyValDict valueForKey:[_nonLoadkeyValDict allKeys][i]] forKey:[_nonLoadkeyValDict allKeys][i]];
                    _urlLength = _urlLength + key.length + value.length + 2;
                }
            }

            for (int j = 0; j < [[_keyValDict allKeys] count]; j++) {
                [_nonLoadkeyValDict removeObjectForKey:[_keyValDict allKeys][j]];
            }

            [self startDataUpload];
        } else {
            _nonLoadkeyValDict = nil;
            _remainkeyValDict = nil;
            _keyValDict = nil;
            _webUrl = nil;
        }
    } else {
        [self addWebView];
        _webView.tag = 1;

        if (_keyValDict) {
            [_keyValDict removeAllObjects];
        } else {
            _keyValDict = [[NSMutableDictionary alloc] init];
        }

        [_keyValDict setValuesForKeysWithDictionary:_remainkeyValDict];

        if (_webUrl) {
            [_webUrl replaceCharactersInRange:NSMakeRange(0, [_webUrl length]) withString:@""];
        } else {
            _webUrl = [[NSMutableString alloc] init];
        }

        _numberOfRunningRequests = -1;
        [self startDataUpload];
    }
}

- (NSString *)urlEncode:(NSString *)string {
    NSMutableString *output = [NSMutableString string];

    const unsigned char *source = (const unsigned char *) [string UTF8String];
    unsigned long sourceLen = strlen((const char *) source);

    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];

        // credit: http://stackoverflow.com/a/12927815/499700
        if (thisChar == ' ') {
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                (thisChar >= 'a' && thisChar <= 'z') ||
                (thisChar >= 'A' && thisChar <= 'Z') ||
                (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }

    return output;
}

- (void)optInPreferenceChanged:(id)sender {
    if ([sender isOn]) {
        [self setOptInPreference:YES];
        [_userDefaults setObject:@"YES" forKey:@"userIsOptIn"];
    } else {
        [self setOptInPreference:NO];
        [_userDefaults setObject:@"NO" forKey:@"userIsOptIn"];
    }
}

- (void)startDataUpload {
    NSString *errorMessage;
    BOOL     hasError = NO;

    if (!_useDirectHTTPCalls && !_viewController) {
        hasError = YES;
        errorMessage = @"view parameter is nil";
    }

    if (!_siteId) {
        hasError = YES;
        errorMessage = @"siteId parameter is nil";
    }

    if (!_appVersion) {
        hasError = YES;
        errorMessage = @"appVersion parameter is nil";
    }

    if (hasError) {
        [self blueKaiLogger:_devMode withString:errorMessage withObject:_keyValDict];
    } else {
        _webView.tag = 1;
        [NSThread detachNewThreadSelector:@selector(startBackgroundJob:) toTarget:self withObject:_keyValDict];
    }
}

- (void)startBackgroundJob:(NSDictionary *)dictionary {
    if (_remainkeyValDict) {
        [_remainkeyValDict removeAllObjects];
    }

    @autoreleasepool {
        NSMutableString *url = [self constructUrl];
        [_webUrl appendString:url];
    }

    _alertShowBool = NO;
    [self updateWebview:_webUrl];
}


- (void)drawWebFrame:(UIWebView *)webView {
    webView.frame = CGRectMake(10, 10, 300, 390);
    _cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_cancelButton setTitle:@"Close" forState:UIControlStateNormal];
    [[_cancelButton layer] setBorderWidth:1.0f];
    [[_cancelButton layer] setCornerRadius:8.0f];
    [[_cancelButton layer] setBorderColor:[UIColor lightGrayColor].CGColor];
    _cancelButton.frame = CGRectMake(245, 26, 55, 25);
    _cancelButton.tag = 10;
    [_cancelButton addTarget:self action:@selector(Cancel:) forControlEvents:UIControlEventTouchUpInside];
    _cancelButton.hidden = YES;
    [_viewController.view addSubview:_cancelButton];
}

- (void)uploadIfNetworkIsAvailable {
    //Check the settings page to find the use data is allowed to send to server or not
    NSString *userPref = [_userDefaults objectForKey:@"settings"];

    if ([userPref isEqualToString:@"YES"]) {
        _numberOfRunningRequests = -1;
        _webLoaded = YES;

        BlueKai_Reachability *networkReachability = [BlueKai_Reachability reachabilityForInternetConnection];
        NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];

        if (networkStatus != NotReachable) {
            [self startDataUpload];
        } else {
            [self webView:nil didFailLoadWithError:nil];
        }

    } else {
        if (!_webView.hidden) {
            _webView.hidden = YES;
        }
    }
}

- (NSMutableString *)constructUrl {
    NSString *serverURL = MOBILE_PROXY_PARTIAL_URL;
    NSMutableString *protocol = [NSMutableString stringWithFormat:@"%@", (_useHttps ? @"https" : @"http")];
    NSMutableString *endPoint = [NSMutableString stringWithFormat:@"%@", (_devMode ? @"m-sandbox.html" : @"m.html")];
    NSMutableString *urlString = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"%@%@%@?site=%@&", protocol, serverURL, endPoint, _siteId]];

    [urlString appendString:[NSString stringWithFormat:@"appVersion=%@", _appVersion]];

    if (_idfa != NULL && [_idfa length] > 0) {
        [urlString appendString:[NSString stringWithFormat:@"&idfa=%@", _idfa]];
    }

    // send the dictionary details to BlueKai server
    _urlLength = urlString.length;

    NSUInteger keyCount = [[_keyValDict allKeys] count];

    for (int i = 0; i < keyCount; i++) {
        NSString *key = [NSString stringWithFormat:@"%@", [_keyValDict allKeys][i]];
        NSString *value = [NSString stringWithFormat:@"%@", _keyValDict[[_keyValDict allKeys][i]]];

        if ((_urlLength + key.length + value.length + 2) > 255) {
            [_remainkeyValDict setValue:value forKey:key];
        } else {
            [urlString appendString:[NSString stringWithFormat:@"&%@=%@", [self urlEncode:[_keyValDict allKeys][i]], [self urlEncode:_keyValDict[[_keyValDict allKeys][i]]]]];
        }
    }

    return urlString;
}

- (void)blueKaiLogger:(BOOL)devMode withString:(NSString *)string withObject:(NSObject *)object {
    if(_devMode) {
        if(object) {
            NSLog(@">>> BlueKaiSDK Log: %@: %@", string, object);
        } else {
            NSLog(@">>> BlueKaiSDK Log: %@", string);
        }
    }
}

- (void) addWebView {
    _webLoaded = NO;
    _useDirectHTTPCalls = NO; // using web view-based communication
    _webView = [[UIWebView alloc] init];
    _webView.scrollView.scrollsToTop = NO;
    _webView.delegate = self;
    _webView.layer.cornerRadius = 5.0f;
    _webView.layer.borderColor = [[UIColor grayColor] CGColor];
    _webView.layer.borderWidth = 4.0f;
    _webView.tag = 1;
    [_viewController.view addSubview:_webView];
    
    if (_devMode) {
        [self drawWebFrame:_webView];
    } else {
        _webView.frame = CGRectMake(10, 10, 1, 1);
    }
    _webView.hidden = YES;
    
}

- (void) baseInitializaton {
    _userDefaults = [NSUserDefaults standardUserDefaults];
    _optInPreference = [_userDefaults objectForKey:@"userIsOptIn"] == NULL ? YES : [[_userDefaults valueForKey:@"userIsOptIn"] boolValue];
    _webUrl = [[NSMutableString alloc] init];
    _nonLoadkeyValDict = [[NSMutableDictionary alloc] init];
    _remainkeyValDict = [[NSMutableDictionary alloc] init];
    _dataParamsDict = [[NSMutableDictionary alloc] init];
    
}

- (void) addDataParam:(NSString *)type WithKey:(NSString *)key AndValue:(NSString *)value {
    NSMutableArray *params = [_dataParamsDict valueForKey:type];
    if(params == NULL){
        params = [[NSMutableArray alloc] init];
        [_dataParamsDict setObject:params forKey:type];
    }
    if( value != NULL) {
        [params addObject:[self urlEncode:[NSString stringWithFormat:@"%@=%@", key, value]]];
    } else {
        [params addObject:key];
    }
}

- (void) addBlueKaiParamWithKey:(NSString *)key AndValue:(NSString *)value {
    [self addDataParam:@"phint" WithKey:[NSString stringWithFormat:@"__bk_%@", key] AndValue:value];
}


@end
