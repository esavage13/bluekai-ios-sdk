#include <QuartzCore/QuartzCore.h>
#import "BlueKai.h"
#import "BlueKai_Reachability.h"
#import "BlueKai_OpenUDID.h"
#import "BlueKai_SBJSON.h"

@implementation BlueKai
@synthesize delegate;

BOOL bluekai_alertShowBool,
     bluekai_useHttps,
     bluekai_webLoaded,
     devMode;

int bluekai_urlStringCount,
    bluekai_numberOfRunningRequests;

UIButton    *bluekai_cancelButton;
UIImageView *bluekai_userCheckImage;

UITapGestureRecognizer *bluekai_tap;
UIWebView              *bluekai_webView;
UIViewController *bluekai_mainView;

NSMutableString *bluekai_webUrl;

NSString *bluekai_appVersion,
         *bluekai_keyString,
         *bluekai_siteId,
         *bluekai_valueString;

NSMutableDictionary *bluekai_keyValDict,
                    *bluekai_nonLoadkeyValDict,
                    *bluekai_remainkeyValDict;

NSUserDefaults *bluekai_userDefaults;


#pragma mark - Public Methods

- (id)init {
    if (self = [super init]) {
        bluekai_appVersion = nil;
        bluekai_mainView = nil;
        bluekai_siteId = nil;
        bluekai_useHttps = NO;
        devMode = NO;
    }

    return self;
}

- (id)initWithSiteId:(NSString *)siteID withAppVersion:(NSString *)version withView:(UIViewController *)view withDevMode:(BOOL)value {
    [self blueKaiLogger:devMode withString:@"init siteId " withObject:siteID];
    [self blueKaiLogger:devMode withString:@"init appVersion " withObject:version];
    [self blueKaiLogger:devMode withString:@"init view " withObject:view];
    [self blueKaiLogger:devMode withString:@"init DevMode " withObject:(value ? @"YES" : @"NO")];

    if (self = [super init]) {
        bluekai_appVersion = version;
        devMode = value;
        bluekai_siteId = nil;
        bluekai_siteId = siteID;
        bluekai_mainView = nil;
        bluekai_mainView = view;
        bluekai_webView = nil;
        bluekai_cancelButton = nil;
        bluekai_webUrl = [[NSMutableString alloc] init];
        bluekai_nonLoadkeyValDict = [[NSMutableDictionary alloc] init];
        bluekai_remainkeyValDict = [[NSMutableDictionary alloc] init];
        bluekai_webLoaded = NO;
        bluekai_webView = [[UIWebView alloc] init];
        bluekai_webView.delegate = self;
        bluekai_webView.layer.cornerRadius = 5.0f;
        bluekai_webView.layer.borderColor = [[UIColor grayColor] CGColor];
        bluekai_webView.layer.borderWidth = 4.0f;
        [bluekai_mainView.view addSubview:bluekai_webView];

        if (devMode) {
            [self drawWebFrame:bluekai_webView];
        } else {
            bluekai_webView.frame = CGRectMake(10, 10, 1, 1);
        }

        if (![[NSUserDefaults standardUserDefaults] objectForKey:@"settings"]) {
            [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"settings"];
        }

        bluekai_webView.hidden = YES;
        /*
         //check the database for previous values
         */
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

        bluekai_keyValDict = [[NSMutableDictionary alloc] initWithDictionary:[self getKeyValueDictionary:[self readStringFromKeyValueFile]]];

        if ([[bluekai_keyValDict allKeys] count] > 1) {
            bluekai_numberOfRunningRequests = -1;
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            BlueKai_Reachability *networkReachability = [BlueKai_Reachability reachabilityForInternetConnection];
            NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];

            if (networkStatus != NotReachable) {
                bluekai_webLoaded = YES;
                bluekai_webView.tag = 1;
                [self startDataUpload];
            } else {
                bluekai_alertShowBool = YES;
                [self webView:nil didFailLoadWithError:nil];
            }
        }
    }
    return self;
}

- (void)setDevMode:(BOOL)mode {
    devMode = mode;

    if (bluekai_mainView != nil && bluekai_siteId != nil && bluekai_appVersion != nil) {
        [self resume];
    }
}

- (void)setAppVersion:(NSString *)version {
    bluekai_appVersion = version;

    if (bluekai_mainView != nil && bluekai_siteId != nil) {
        [self resume];
    }
}

- (void)setViewController:(UIViewController *)view {
    [self blueKaiLogger:devMode withString:@"setViewController" withObject:view];

    bluekai_mainView = view;

    if (bluekai_siteId != nil) {
        bluekai_webView = nil;
        bluekai_cancelButton = nil;

        if (bluekai_webUrl == nil) {
            bluekai_webUrl = [[NSMutableString alloc] init];
        } else {
            [bluekai_webUrl replaceCharactersInRange:NSMakeRange(0, [bluekai_webUrl length]) withString:@""];
        }

        bluekai_webView = [[UIWebView alloc] init];
        bluekai_webView.delegate = self;
        bluekai_webView.layer.cornerRadius = 5.0f;
        bluekai_webView.layer.borderColor = [[UIColor grayColor] CGColor];
        bluekai_webView.layer.borderWidth = 4.0f;
        [bluekai_mainView.view addSubview:bluekai_webView];

        if(devMode) {
            [self drawWebFrame:bluekai_webView];
        } else {
            bluekai_webView.frame = CGRectMake(1, 1, 1, 1);
        }

        bluekai_webView.hidden = YES;
        [self resume];
    }
}

- (void)setSiteId:(int)siteId {
    [self blueKaiLogger:devMode withString:@"setSiteId" withObject:[NSString stringWithFormat:@"%i", siteId]];

    bluekai_siteId = [NSString stringWithFormat:@"%d", siteId];

    if (bluekai_mainView != nil) {
        [self resume];
    }
}

- (void)resume {
    if (bluekai_webUrl) {
        [bluekai_webUrl replaceCharactersInRange:NSMakeRange(0, [bluekai_webUrl length]) withString:@""];
    } else {
        bluekai_webUrl = [[NSMutableString alloc] init];
    }

    bluekai_keyValDict = [[NSMutableDictionary alloc] initWithDictionary:[self getKeyValueDictionary:[self readStringFromKeyValueFile]]];

    if ([[bluekai_keyValDict allKeys] count] > 0) {
        bluekai_numberOfRunningRequests = -1;
        BlueKai_Reachability *networkReachability = [BlueKai_Reachability reachabilityForInternetConnection];
        NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];

        if (networkStatus != NotReachable) {
            bluekai_webView.tag = 1;
            [self startDataUpload];
        } else {
            [self webView:nil didFailLoadWithError:nil];
        }

    }
}

- (void)put:(NSString *)key withValue:(NSString *)value {
    [self blueKaiLogger:devMode withString:@"put:key:value => key" withObject:key];
    [self blueKaiLogger:devMode withString:@"put:key:value => value" withObject:value];

    if (bluekai_webLoaded) {
        [bluekai_nonLoadkeyValDict setValue:value forKey:key];
    } else {
        if (bluekai_webUrl == nil) {
            bluekai_webUrl = [[NSMutableString alloc] init];
        } else {
            [bluekai_webUrl replaceCharactersInRange:NSMakeRange(0, [bluekai_webUrl length]) withString:@""];
        }

        bluekai_keyString = nil;
        bluekai_valueString = nil;
        bluekai_keyString = [key copy];
        bluekai_valueString = [value copy];

        //Check the settings page to find the use data is allowed to send to server or not
        if (bluekai_keyValDict != nil) {
            [bluekai_keyValDict removeAllObjects];
        } else {
            bluekai_keyValDict = [[NSMutableDictionary alloc] init];
        }

        [bluekai_keyValDict setValue:bluekai_valueString forKey:bluekai_keyString];

        NSString *user_value = [[NSUserDefaults standardUserDefaults] objectForKey:@"settings"];

        if ([user_value isEqualToString:@"YES"]) {
            bluekai_numberOfRunningRequests = -1;
            bluekai_webLoaded = YES;

            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            BlueKai_Reachability *networkReachability = [BlueKai_Reachability reachabilityForInternetConnection];
            NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];

            if (networkStatus != NotReachable) {
                [self startDataUpload];
            } else {
                [self webView:nil didFailLoadWithError:nil];
            }

        } else {
            if (!bluekai_webView.hidden) {
                bluekai_webView.hidden = YES;
            }
        }
    }
}

- (void)put:(NSDictionary *)dictionary {
    [self blueKaiLogger:devMode withString:@"put:dictionary" withObject:dictionary];

    if (bluekai_webUrl) {
        [bluekai_webUrl replaceCharactersInRange:NSMakeRange(0, [bluekai_webUrl length]) withString:@""];
    } else {
        bluekai_webUrl = [[NSMutableString alloc] init];
    }

    if (bluekai_keyValDict) {
        [bluekai_keyValDict removeAllObjects];
    } else {
        bluekai_keyValDict = [[NSMutableDictionary alloc] init];
    }

    [bluekai_keyValDict setValuesForKeysWithDictionary:dictionary];

    //Check the settings page to find the use data is allowed to send to server or not
    NSString *value = [[NSUserDefaults standardUserDefaults] objectForKey:@"settings"];

    if ([value isEqualToString:@"YES"]) {
        bluekai_numberOfRunningRequests = -1;
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        BlueKai_Reachability *networkReachability = [BlueKai_Reachability reachabilityForInternetConnection];
        NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];

        if (networkStatus != NotReachable) {
            [self startDataUpload];
        } else {
            [self webView:nil didFailLoadWithError:nil];
        }
    } else {
        if (!bluekai_webView.hidden) {
            bluekai_webView.hidden = YES;
        }
    }
}

- (void)setOptInPreference:(BOOL)optIn {
    [self blueKaiLogger:devMode withString:@"setOptInPreference:OptIn" withObject:(optIn ? @"true" : @"false")];

    bluekai_userDefaults = [NSUserDefaults standardUserDefaults];
    [bluekai_userDefaults setObject:(optIn ? @"YES" : @"NO") forKey:@"KeyToUserData"];

    [self saveSettings:nil];
    [self updateServer];
}

- (void)useHttps:(BOOL)secured {
    bluekai_useHttps = secured;
}

- (void)showSettingsScreen {
    [self showSettingsScreenWithBackgroundColor:nil];
}

- (void)showSettingsScreenWithBackgroundColor:(UIColor *)backgroundColor {
//    NSArray *array = [bluekai_mainView.view subviews];
//    for (UIView *view in array) {
//        if(![view isKindOfClass:[UIWebView class]]) {
//            [view removeFromSuperview];
//        }
//    }

    UIColor *bgColor = backgroundColor ? backgroundColor : [UIColor whiteColor];

    bluekai_mainView.view.backgroundColor = bgColor;
    bluekai_userDefaults = [NSUserDefaults standardUserDefaults];
    bluekai_userCheckImage = [[UIImageView alloc] initWithFrame:CGRectMake(25, 100, 40, 40)];

    UIGraphicsBeginImageContext(bluekai_userCheckImage.frame.size);
    NSString *value = [[NSUserDefaults standardUserDefaults] objectForKey:@"settings"];

    if ([value isEqualToString:@"YES"]) {
        [[UIImage imageNamed:@"chk-1"] drawInRect:bluekai_userCheckImage.bounds];
        [bluekai_userDefaults setObject:@"YES" forKey:@"KeyToUserData"];
        bluekai_userCheckImage.tag = 0;
    } else {
        [[UIImage imageNamed:@"unchk-1"] drawInRect:bluekai_userCheckImage.bounds];
        [bluekai_userDefaults setObject:@"NO" forKey:@"KeyToUserData"];
        bluekai_userCheckImage.tag = 1;
    }

    UIImage *lblimage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    bluekai_userCheckImage.image = lblimage;
    bluekai_userCheckImage.userInteractionEnabled = YES;
    bluekai_tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userData_Change:)];
    bluekai_tap.delegate = self;
    [bluekai_userCheckImage addGestureRecognizer:bluekai_tap];
    [bluekai_mainView.view addSubview:bluekai_userCheckImage];

    UILabel *usrData_lbl = [[UILabel alloc] initWithFrame:CGRectMake(75, 95, 240, 50)];
    usrData_lbl.textColor = [UIColor blackColor];
    usrData_lbl.backgroundColor = [UIColor clearColor];
    usrData_lbl.textAlignment = NSTextAlignmentLeft;
    usrData_lbl.numberOfLines = 0;
    usrData_lbl.lineBreakMode = NSLineBreakByWordWrapping;
    usrData_lbl.font = [UIFont systemFontOfSize:14];
    usrData_lbl.text = @"Allow Bluekai to receive my data";
    [bluekai_mainView.view addSubview:usrData_lbl];

    UILabel *tclbl = [[UILabel alloc] initWithFrame:CGRectMake(25, 235, 280, 50)];
    tclbl.textColor = [UIColor blackColor];
    tclbl.backgroundColor = [UIColor clearColor];
    tclbl.textAlignment = NSTextAlignmentLeft;
    tclbl.numberOfLines = 3;
    tclbl.lineBreakMode = NSLineBreakByWordWrapping;
    tclbl.font = [UIFont systemFontOfSize:14];
    tclbl.text = @"The BlueKai privacy policy is available";
    [bluekai_mainView.view addSubview:tclbl];

    UIButton *Here = [UIButton buttonWithType:UIButtonTypeCustom];
    Here.frame = CGRectMake(256, 253, 50, 14);
    [Here setTitle:@"here" forState:UIControlStateNormal];
    Here.titleLabel.font = [UIFont systemFontOfSize:14];
    [Here addTarget:self action:@selector(termsConditions:) forControlEvents:UIControlEventTouchUpInside];
    [Here setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [bluekai_mainView.view addSubview:Here];

    UIButton *savebtn = [UIButton buttonWithType:UIButtonTypeCustom];
    savebtn.frame = CGRectMake(75, 290, 80, 35);
    [savebtn setTitle:@"Save" forState:UIControlStateNormal];
    [savebtn.layer setBorderWidth:2.0f];
    [savebtn.layer setBorderColor:[[UIColor grayColor] CGColor]];
    [savebtn.layer setCornerRadius:5.0f];
    [savebtn setBackgroundColor:[UIColor whiteColor]];
    [savebtn addTarget:self action:@selector(saveSettings:) forControlEvents:UIControlEventTouchUpInside];
    [savebtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [bluekai_mainView.view addSubview:savebtn];

    UIButton *cancelbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelbtn.frame = CGRectMake(175, 290, 80, 35);
    [cancelbtn setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelbtn.layer setBorderWidth:2.0f];
    [cancelbtn.layer setBorderColor:[[UIColor grayColor] CGColor]];
    [cancelbtn.layer setCornerRadius:5.0f];
    [cancelbtn setBackgroundColor:[UIColor whiteColor]];
    [cancelbtn addTarget:self action:@selector(Cancelbtn:) forControlEvents:UIControlEventTouchUpInside];
    [cancelbtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [bluekai_mainView.view addSubview:cancelbtn];
    [bluekai_mainView.view addSubview:bluekai_webView];
    [bluekai_mainView.view addSubview:bluekai_cancelButton];
}


#pragma mark - Deprecated Methods

- (id)initWithArgs:(BOOL)value withSiteId:(NSString *)siteID withAppVersion:(NSString *)version withView:(UIViewController *)view {
    return [self initWithSiteId:siteID withAppVersion:version withView:view withDevMode:value];
}

- (void)setPreference:(BOOL)optIn {
    [self setOptInPreference:optIn];
}


#pragma mark - Objective-C Method overrides

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p, %@>",
                                        [self class],
                                        self,
                                        @{
                                            @"siteID": bluekai_siteId,
                                            @"appVersion": bluekai_appVersion,
                                            @"view": bluekai_mainView,
                                            @"devMode": devMode ? @"YES" : @"NO",
                                            @"useHTTPS": bluekai_useHttps ? @"YES" : @"NO"
                                        }];
}

- (NSString *)debugDescription {
    return [self description];
}


#pragma mark - IBActions

- (IBAction)termsConditions:(id)sender {
    NSString *shareUrlString = [NSString stringWithFormat:@"http://www.bluekai.com/consumers_privacyguidelines.php"];

    NSURL *HereUrl = [[NSURL alloc] initWithString:shareUrlString];
    //Create the URL object

    [[UIApplication sharedApplication] openURL:HereUrl];
    //Launch Safari with the URL you created
}

- (IBAction)Cancelbtn:(id)sender {
}

- (IBAction)Cancel:(id)sender {
    bluekai_webView.hidden = YES;
    bluekai_cancelButton.hidden = YES;
}

- (IBAction)saveSettings:(id)sender {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSString *userDataValue = [bluekai_userDefaults objectForKey:@"KeyToUserData"];
    [[NSUserDefaults standardUserDefaults] setObject:userDataValue forKey:@"settings"];
    [self updateServer];
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

- (NSString *)getKeyValueJSON:(NSMutableDictionary *)keyvalues {
    @try {
        NSMutableDictionary *dict3 = [[NSMutableDictionary alloc] initWithDictionary:keyvalues];
        BlueKai_SBJsonWriter *sb = [[BlueKai_SBJsonWriter alloc] init];
        NSString *jsonString = [sb stringWithObject:dict3];

        return jsonString;
    }
    @catch (NSException *ex) {
        [self blueKaiLogger:devMode withString:@"Exception is " withObject:ex];

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
    [self blueKaiLogger:devMode withString:@"getAttemptsJSON: " withObject:keyValues];

    @try {
        NSMutableDictionary *dict3 = [[NSMutableDictionary alloc] initWithDictionary:keyValues];
        BlueKai_SBJsonWriter *sb = [[BlueKai_SBJsonWriter alloc] init];
        NSString *jsonString = [sb stringWithObject:dict3];
        return jsonString;
    }

    @catch (NSException *ex) {
        [self blueKaiLogger:devMode withString:@"Exception is " withObject:ex];
        return nil;
    }
}

- (NSDictionary *)getAttemptsDictionary:(NSString *)jsonString {
    [self blueKaiLogger:devMode withString:@"getAttemptsDictionary: " withObject:jsonString];
    BlueKai_SBJSON *sparser = [[BlueKai_SBJSON alloc] init];
    NSDictionary *realData = (NSDictionary *) [sparser objectWithString:jsonString error:nil];
    return realData;
}


- (void)updateWebview:(NSString *)url {
    [bluekai_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if (bluekai_numberOfRunningRequests != 0) {
        bluekai_numberOfRunningRequests = 0;

        // to avoid the "Weak receiver may be unpredictably null in ARC mode" warning
        id <OnDataPostedListener> localDelegate = delegate;

        if ([localDelegate respondsToSelector:@selector(onDabluekai_taposted:)]) {
            [localDelegate onDataPosted:FALSE];
        }

        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

        for (int i = 0; i < [[bluekai_keyValDict allKeys] count]; i++) {
            if (![bluekai_remainkeyValDict valueForKey:[bluekai_keyValDict allKeys][i]]) {
                NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithDictionary:[self getKeyValueDictionary:[self readStringFromKeyValueFile]]];
                NSMutableDictionary *atmt_dictionary = [[NSMutableDictionary alloc] initWithDictionary:[self getAttemptsDictionary:[self readStringFromAttemptsFile]]];
                int attempts = [atmt_dictionary[[bluekai_keyValDict allKeys][i]] intValue];

                if (attempts == 0) {
                    dictionary[[bluekai_keyValDict allKeys][i]] = [bluekai_keyValDict valueForKey:[bluekai_keyValDict allKeys][i]];
                    atmt_dictionary[[bluekai_keyValDict allKeys][i]] = @"1";
                } else {
                    if (attempts < 5) {
                        [atmt_dictionary removeObjectForKey:[bluekai_keyValDict allKeys][i]];
                        atmt_dictionary[[bluekai_keyValDict allKeys][i]] = [NSString stringWithFormat:@"%d", attempts + 1];
                    } else {
                        [dictionary removeObjectForKey:[bluekai_keyValDict allKeys][i]];
                        [atmt_dictionary removeObjectForKey:[bluekai_keyValDict allKeys][i]];
                    }
                }

                [self writeStringToKeyValueFile:[self getKeyValueJSON:dictionary]];
                [self writeStringToAttemptsFile:[self getAttemptsJSON:atmt_dictionary]];
            }
        }

        bluekai_webLoaded = NO;

        if (bluekai_remainkeyValDict != nil || bluekai_nonLoadkeyValDict != nil) {
            if ([bluekai_remainkeyValDict count] != 0 || [bluekai_nonLoadkeyValDict count] != 0) {
                [self loadAnotherRequest];
            }
        }
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    // if "bluekai_numberOfRunningRequests" is not -1, +1; otherwise (0 or -1) set it back to 1
    bluekai_numberOfRunningRequests = bluekai_numberOfRunningRequests != -1 ? bluekai_numberOfRunningRequests + 1 : 1;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    bluekai_numberOfRunningRequests = bluekai_numberOfRunningRequests - 1;
    // to avoid the "Weak receiver may be unpredictably null in ARC mode" warning
    id <OnDataPostedListener> localDelegate = delegate;

    if (bluekai_numberOfRunningRequests == 0) {
        if (!bluekai_alertShowBool) {
            if (bluekai_webView.tag == 1) {
                //Delete the key and value pairs from database after sent to server.
                for (int k = 0; k < [bluekai_keyValDict count]; k++) {
                    if (![bluekai_remainkeyValDict valueForKey:[bluekai_keyValDict allKeys][k]]) {
                        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithDictionary:[self getKeyValueDictionary:[self readStringFromKeyValueFile]]];
                        NSMutableDictionary *atmt_dictionary = [[NSMutableDictionary alloc] initWithDictionary:[self getAttemptsDictionary:[self readStringFromAttemptsFile]]];
                        int attempts = [atmt_dictionary[[bluekai_keyValDict allKeys][k]] intValue];

                        if (attempts != 0) {
                            [dictionary removeObjectForKey:[bluekai_keyValDict allKeys][k]];
                            [atmt_dictionary removeObjectForKey:[bluekai_keyValDict allKeys][k]];
                            [self writeStringToKeyValueFile:[self getKeyValueJSON:dictionary]];
                            [self writeStringToAttemptsFile:[self getAttemptsJSON:atmt_dictionary]];
                        }
                    }
                }
            }

            if (devMode) {
                bluekai_webView.hidden = NO;
                bluekai_cancelButton.hidden = NO;
            }

            bluekai_webLoaded = NO;
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

            if ([localDelegate respondsToSelector:@selector(onDataPosted:)]) {
                [localDelegate onDataPosted:TRUE];
            }

            [self blueKaiLogger:devMode withString:@"URL Passed" withObject:webView.request.URL];
            bluekai_alertShowBool = YES;

            if (bluekai_remainkeyValDict != nil || bluekai_nonLoadkeyValDict != nil) {
                if ([bluekai_remainkeyValDict count] != 0 || [bluekai_nonLoadkeyValDict count] != 0) {
                    [self loadAnotherRequest];
                }
            }

            NSArray *webviews = [bluekai_mainView.view subviews];
            int web_count = 0;
            int btn_count = 0;

            for (UIView *view in webviews) {
                if ([view isKindOfClass:[UIWebView class]]) {
                    web_count++;
                } else {
                    if ([view isKindOfClass:[UIButton class]]) {
                        if (view.tag == 10) {
                            btn_count++;
                        }
                    }
                }
            }

            if (web_count > 1) {
                for (UIView *view in webviews) {
                    if ([view isKindOfClass:[UIWebView class]]) {
                        if (web_count >= 2) {
                            [view removeFromSuperview];
                            web_count--;
                        } else {
                            view.hidden = YES;
                        }
                    } else {
                        if ([view isKindOfClass:[UIButton class]]) {
                            if (view.tag == 10) {
                                if (btn_count >= 2) {
                                    [view removeFromSuperview];
                                    btn_count--;
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
    [self blueKaiLogger:devMode withString:@"loadAnotherRequest" withObject:nil];

    if ([bluekai_remainkeyValDict count] == 0) {
        if ([bluekai_nonLoadkeyValDict count] != 0) {
            bluekai_webView = [[UIWebView alloc] init];
            bluekai_webView.delegate = self;
            bluekai_webView.layer.cornerRadius = 5.0f;
            bluekai_webView.layer.borderColor = [[UIColor grayColor] CGColor];
            bluekai_webView.layer.borderWidth = 4.0f;
            bluekai_webView.hidden = YES;
            [bluekai_mainView.view addSubview:bluekai_webView];

            [self blueKaiLogger:devMode withString:@"3.1" withObject:nil];

            if (devMode) {
                [self drawWebFrame:bluekai_webView];
            } else {
                bluekai_webView.frame = CGRectMake(10, 10, 1, 1);
            }

            bluekai_webLoaded = NO;

            if (bluekai_keyValDict) {
                [bluekai_keyValDict removeAllObjects];
            } else {
                bluekai_keyValDict = [[NSMutableDictionary alloc] init];
            }

            bluekai_numberOfRunningRequests = -1;

            if (bluekai_webUrl) {
                [bluekai_webUrl replaceCharactersInRange:NSMakeRange(0, [bluekai_webUrl length]) withString:@""];
            } else {
                bluekai_webUrl = [[NSMutableString alloc] init];
            }

            //Code to send the multiple values for every request.

            for (int i = 0; i < [[bluekai_nonLoadkeyValDict allKeys] count]; i++) {
                NSString *key = [NSString stringWithFormat:@"%@", [bluekai_nonLoadkeyValDict allKeys][i]];
                NSString *value = [NSString stringWithFormat:@"%@", bluekai_nonLoadkeyValDict[[bluekai_nonLoadkeyValDict allKeys][i]]];

                if ((bluekai_urlStringCount + key.length + value.length + 2) <= 255) {
                    [bluekai_keyValDict setValue:[bluekai_nonLoadkeyValDict valueForKey:[bluekai_nonLoadkeyValDict allKeys][i]] forKey:[bluekai_nonLoadkeyValDict allKeys][i]];
                    bluekai_urlStringCount = bluekai_urlStringCount + key.length + value.length + 2;
                }
            }

            for (int j = 0; j < [[bluekai_keyValDict allKeys] count]; j++) {
                [bluekai_nonLoadkeyValDict removeObjectForKey:[bluekai_keyValDict allKeys][j]];
            }

            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            [self startDataUpload];
        } else {
            bluekai_nonLoadkeyValDict = nil;
            bluekai_remainkeyValDict = nil;
            bluekai_keyValDict = nil;
            bluekai_webUrl = nil;
        }
    } else {
        bluekai_webView = [[UIWebView alloc] init];
        bluekai_webView.delegate = self;
        bluekai_webView.layer.cornerRadius = 5.0f;
        bluekai_webView.layer.borderColor = [[UIColor grayColor] CGColor];
        bluekai_webView.layer.borderWidth = 4.0f;
        bluekai_webView.tag = 1;
        bluekai_webView.hidden = YES;
        [bluekai_mainView.view addSubview:bluekai_webView];

        [self blueKaiLogger:devMode withString:@"3.2" withObject:nil];

        if (devMode) {
            [self drawWebFrame:bluekai_webView];
        } else {
            bluekai_webView.frame = CGRectMake(10, 10, 1, 1);
        }

        if (bluekai_keyValDict) {
            [bluekai_keyValDict removeAllObjects];
        } else {
            bluekai_keyValDict = [[NSMutableDictionary alloc] init];
        }

        [bluekai_keyValDict setValuesForKeysWithDictionary:bluekai_remainkeyValDict];

        if (bluekai_webUrl) {
            [bluekai_webUrl replaceCharactersInRange:NSMakeRange(0, [bluekai_webUrl length]) withString:@""];
        } else {
            bluekai_webUrl = [[NSMutableString alloc] init];
        }

        bluekai_numberOfRunningRequests = -1;
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        [self startDataUpload];
    }
}

- (void)startBackgroundJob:(NSDictionary *)dictionary {
    NSString *serverURL = @"://mobileproxy.bluekai.com/";
    NSMutableString *protocol = [NSMutableString stringWithFormat:@"%@", (bluekai_useHttps ? @"https" : @"http")];
    NSMutableString *endPoint = [NSMutableString stringWithFormat:@"%@", (devMode ? @"m-sandbox.html" : @"m.html")];

    [self blueKaiLogger:devMode withString:@"useHttps" withObject:(bluekai_useHttps ? @"YES" : @"NO")];

    if (bluekai_remainkeyValDict) {
        [bluekai_remainkeyValDict removeAllObjects];
    }

    @autoreleasepool {
        // send the dictionary details to BlueKai server
        NSMutableString *url_string = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"%@%@%@?site=%@&", protocol, serverURL, endPoint, bluekai_siteId]];
        [url_string appendString:[NSString stringWithFormat:@"appVersion=%@", bluekai_appVersion]];
        [url_string appendString:[NSString stringWithFormat:@"&identifierForVendor=%@", [NSString stringWithFormat:@"%@", [self getVendorID]]]];
        bluekai_urlStringCount = url_string.length;

        for (int i = 0; i < [[bluekai_keyValDict allKeys] count]; i++) {
            NSString *key = [NSString stringWithFormat:@"%@", [bluekai_keyValDict allKeys][i]];
            NSString *value = [NSString stringWithFormat:@"%@", bluekai_keyValDict[[bluekai_keyValDict allKeys][i]]];

            if ((url_string.length + key.length + value.length + 2) > 255) {
                [bluekai_remainkeyValDict setValue:value forKey:key];
            } else {
                [url_string appendString:[NSString stringWithFormat:@"&%@=%@", [self urlEncode:[bluekai_keyValDict allKeys][i]], [self urlEncode:bluekai_keyValDict[[bluekai_keyValDict allKeys][i]]]]];
            }
        }

        [self blueKaiLogger:devMode withString:@"Encoded URL: " withObject:url_string];
        [bluekai_webUrl appendString:url_string];
    }
    bluekai_alertShowBool = NO;

    [self updateWebview:bluekai_webUrl];
}

- (NSString *)urlEncode:(NSString *)string {
    NSMutableString *output = [NSMutableString string];

    const unsigned char *source = (const unsigned char *) [string UTF8String];
    int sourceLen = strlen((const char *) source);

    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];

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

- (NSString *)getVendorID {
    NSString *vendorId;
    vendorId = [BlueKai_OpenUDID value];
    return vendorId;
}

- (void)userData_Change:(UITapGestureRecognizer *)recognizer {
    if (bluekai_userCheckImage.tag == 1) {
        UIGraphicsBeginImageContext(bluekai_userCheckImage.frame.size);
        [[UIImage imageNamed:@"chk-1"] drawInRect:bluekai_userCheckImage.bounds];
        UIImage *appsimage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        bluekai_userCheckImage.image = appsimage;
        [bluekai_userDefaults setObject:@"YES" forKey:@"KeyToUserData"];
        bluekai_userCheckImage.tag = 0;
    } else {
        UIGraphicsBeginImageContext(bluekai_userCheckImage.frame.size);
        [[UIImage imageNamed:@"unchk-1"] drawInRect:bluekai_userCheckImage.bounds];
        UIImage *appsimage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        bluekai_userCheckImage.image = appsimage;
        [bluekai_userDefaults setObject:@"NO" forKey:@"KeyToUserData"];
        bluekai_userCheckImage.tag = 1;
    }
}

- (void)updateServer {
    if (bluekai_webUrl) {
        [bluekai_webUrl replaceCharactersInRange:NSMakeRange(0, [bluekai_webUrl length]) withString:@""];
    } else {
        bluekai_webUrl = [[NSMutableString alloc] init];
    }

    bluekai_keyValDict = [[NSMutableDictionary alloc] init];

    if ([[bluekai_userDefaults objectForKey:@"KeyToUserData"] isEqualToString:@"YES"]) {
        bluekai_valueString = @"1";
    } else {
        bluekai_valueString = @"0";
    }

    [bluekai_keyValDict setValue:bluekai_valueString forKey:[NSString stringWithFormat:@"TC"]];
    bluekai_numberOfRunningRequests = -1;
    BlueKai_Reachability *networkReachability = [BlueKai_Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];

    if (networkStatus != NotReachable) {
        [self startDataUpload];
    } else {
        [self webView:nil didFailLoadWithError:nil];
    }
}

- (void)startDataUpload {
    if (bluekai_mainView != nil) {
        if (bluekai_siteId != nil) {
            if (bluekai_appVersion != nil) {
                [NSThread detachNewThreadSelector:@selector(startBackgroundJob:) toTarget:self withObject:bluekai_keyValDict];
            } else {
                [self blueKaiLogger:devMode withString:@"appVersion parameter is nil" withObject:nil];

                for (int i = 0; i < [[bluekai_keyValDict allKeys] count]; i++) {
                    if (![bluekai_remainkeyValDict valueForKey:[bluekai_keyValDict allKeys][i]]) {
                        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithDictionary:[self getKeyValueDictionary:[self readStringFromKeyValueFile]]];
                        NSMutableDictionary *atmt_dictionary = [[NSMutableDictionary alloc] initWithDictionary:[self getAttemptsDictionary:[self readStringFromAttemptsFile]]];
                        int attempts = [atmt_dictionary[[bluekai_keyValDict allKeys][i]] intValue];

                        if (attempts == 0) {
                            dictionary[[bluekai_keyValDict allKeys][i]] = [bluekai_keyValDict valueForKey:[bluekai_keyValDict allKeys][i]];
                            atmt_dictionary[[bluekai_keyValDict allKeys][i]] = @"1";
                        } else {
                            if (attempts < 5) {
                                [atmt_dictionary removeObjectForKey:[bluekai_keyValDict allKeys][i]];
                                atmt_dictionary[[bluekai_keyValDict allKeys][i]] = [NSString stringWithFormat:@"%d", attempts + 1];
                            } else {
                                [dictionary removeObjectForKey:[bluekai_keyValDict allKeys][i]];
                                [atmt_dictionary removeObjectForKey:[bluekai_keyValDict allKeys][i]];
                            }
                        }

                        [self writeStringToKeyValueFile:[self getKeyValueJSON:dictionary]];
                        [self writeStringToAttemptsFile:[self getAttemptsJSON:atmt_dictionary]];
                    }
                }

                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            }
        } else {
            NSString *errorMsg = bluekai_appVersion ? @"siteId parameter is nil" : @"siteId and appVersion parameters are nil";
            [self blueKaiLogger:devMode withString:errorMsg withObject:nil];

            for (int i = 0; i < [[bluekai_keyValDict allKeys] count]; i++) {
                if (![bluekai_remainkeyValDict valueForKey:[bluekai_keyValDict allKeys][i]]) {
                    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithDictionary:[self getKeyValueDictionary:[self readStringFromKeyValueFile]]];
                    NSMutableDictionary *atmt_dictionary = [[NSMutableDictionary alloc] initWithDictionary:[self getAttemptsDictionary:[self readStringFromAttemptsFile]]];
                    int attempts = [atmt_dictionary[[bluekai_keyValDict allKeys][i]] intValue];
                    if (attempts == 0) {
                        dictionary[[bluekai_keyValDict allKeys][i]] = [bluekai_keyValDict valueForKey:[bluekai_keyValDict allKeys][i]];
                        atmt_dictionary[[bluekai_keyValDict allKeys][i]] = @"1";
                    } else {
                        if (attempts < 5) {
                            [atmt_dictionary removeObjectForKey:[bluekai_keyValDict allKeys][i]];
                            atmt_dictionary[[bluekai_keyValDict allKeys][i]] = [NSString stringWithFormat:@"%d", attempts + 1];
                        } else {
                            [dictionary removeObjectForKey:[bluekai_keyValDict allKeys][i]];
                            [atmt_dictionary removeObjectForKey:[bluekai_keyValDict allKeys][i]];
                        }
                    }

                    [self writeStringToKeyValueFile:[self getKeyValueJSON:dictionary]];
                    [self writeStringToAttemptsFile:[self getAttemptsJSON:atmt_dictionary]];
                }
            }

            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        }
    } else {
        if (bluekai_siteId && bluekai_appVersion) {
            [self blueKaiLogger:devMode withString:@"view parameter is nil" withObject:nil];
        } else {
            NSString *errorMsg;

            if (bluekai_siteId) {
                errorMsg = bluekai_appVersion ? @"view parameter is nil" : @"view and appVersion parameters are nil";
                [self blueKaiLogger:devMode withString:errorMsg withObject:nil];
            } else {
                errorMsg = bluekai_appVersion ? @"siteId and view parameters are nil" : @"siteId, view and appVersion parameters are nil";
                [self blueKaiLogger:devMode withString:errorMsg withObject:nil];
            }
        }

        for (int i = 0; i < [[bluekai_keyValDict allKeys] count]; i++) {
            if (![bluekai_remainkeyValDict valueForKey:[bluekai_keyValDict allKeys][i]]) {
                NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithDictionary:[self getKeyValueDictionary:[self readStringFromKeyValueFile]]];
                NSMutableDictionary *atmt_dictionary = [[NSMutableDictionary alloc] initWithDictionary:[self getAttemptsDictionary:[self readStringFromAttemptsFile]]];
                int attempts = [atmt_dictionary[[bluekai_keyValDict allKeys][i]] intValue];

                if (attempts == 0) {
                    dictionary[[bluekai_keyValDict allKeys][i]] = [bluekai_keyValDict valueForKey:[bluekai_keyValDict allKeys][i]];
                    atmt_dictionary[[bluekai_keyValDict allKeys][i]] = @"1";
                } else {
                    if (attempts < 5) {
                        [atmt_dictionary removeObjectForKey:[bluekai_keyValDict allKeys][i]];
                        atmt_dictionary[[bluekai_keyValDict allKeys][i]] = [NSString stringWithFormat:@"%d", attempts + 1];
                    } else {
                        [dictionary removeObjectForKey:[bluekai_keyValDict allKeys][i]];
                        [atmt_dictionary removeObjectForKey:[bluekai_keyValDict allKeys][i]];
                    }
                }

                [self writeStringToKeyValueFile:[self getKeyValueJSON:dictionary]];
                [self writeStringToAttemptsFile:[self getAttemptsJSON:atmt_dictionary]];
            }
        }

        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
}

- (void)drawWebFrame:(UIWebView *)webView {
    webView.frame = CGRectMake(10, 10, 300, 390);
    bluekai_cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    bluekai_cancelButton.frame = CGRectMake(281, 9, 30, 30);
    bluekai_cancelButton.tag = 10;
    [bluekai_cancelButton setImage:[UIImage imageNamed:@"btn-sub-del-op"] forState:UIControlStateNormal];
    [bluekai_cancelButton addTarget:self action:@selector(Cancel:) forControlEvents:UIControlEventTouchUpInside];
    bluekai_cancelButton.hidden = YES;
    [bluekai_mainView.view addSubview:bluekai_cancelButton];
}

- (void)blueKaiLogger:(BOOL)devMode withString:(NSString *)string withObject:(NSObject *)object {
    if(devMode) {
        if(object == nil) {
            NSLog(@">>> BlueKaiSDK Log: %@", string);
        } else {
            NSLog(@">>> BlueKaiSDK Log: %@: %@", string, object);
        }
    }
}

@end
