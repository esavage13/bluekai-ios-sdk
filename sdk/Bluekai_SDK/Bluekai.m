#include <QuartzCore/QuartzCore.h>
#import "BlueKai.h"
#import "BlueKai_Reachability.h"
#import "BlueKai_OpenUDID.h"
#import "SBJSON.h"

NSString *const server_URL = @"http://bluekai.github.io/m.html";

@implementation BlueKai
@synthesize delegate;

BOOL alertShowBool;
BOOL devMode;
BOOL loadFailedBool;
BOOL web_Loaded;
int urlStringCount;
int numberOfRunningRequests;

UIAlertView *alert_View;
UIButton    *cncl_Btn;
UIImageView *usrcheck_image,
            *tccheck_image;

UITapGestureRecognizer *tap;
UIWebView              *web;
UIViewController *main_View;

NSArray         *checkimage;
NSMutableString *web_URL;

NSString *appVersion,
         *key_str,
         *siteId,
         *value_str;

NSMutableDictionary *keyVal_dict,
                    *nonLoadkeyVal_dict,
                    *remainkeyVal_dict;

NSUserDefaults *user_defaults;


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
        SBJsonWriter *sb = [[SBJsonWriter alloc] init];
        NSString *jsonString = [sb stringWithObject:dict3];

        return jsonString;
    }
    @catch (NSException *ex) {
        NSLog(@"Exception is %@", ex);

        return nil;
    }
}

- (NSDictionary *)getKeyValueDictionary:(NSString *)jsonString {
    SBJSON *sparser = [[SBJSON alloc] init];
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

- (NSString *)getAttemptsJSON:(NSMutableDictionary *)keyvalues {
    @try {
        NSMutableDictionary *dict3 = [[NSMutableDictionary alloc] initWithDictionary:keyvalues];
        SBJsonWriter *sb = [[SBJsonWriter alloc] init];
        NSString *jsonString = [sb stringWithObject:dict3];
        return jsonString;
    }

    @catch (NSException *ex) {
        NSLog(@"Exception is %@", ex);
        return nil;
    }
}

- (NSDictionary *)getAttempsDictionary:(NSString *)jsonString {
    SBJSON *sparser = [[SBJSON alloc] init];
    NSDictionary *realdata = (NSDictionary *) [sparser objectWithString:jsonString error:nil];
    return realdata;
}

- (id)initWithArgs:(BOOL)value withSiteId:(NSString *)siteID withAppVersion:(NSString *)version withView:(UIViewController *)view {
    if (self = [super init]) {
        //        [Database copyDataBaseIfNeeded];
        //        [Database openDataBase:[Database getDBPath]];

        appVersion = version;
        devMode = value;
        siteId = nil;
        siteId = siteID;
        main_View = nil;
        main_View = view;
        web = nil;
        cncl_Btn = nil;
        web_URL = [[NSMutableString alloc] init];
        nonLoadkeyVal_dict = [[NSMutableDictionary alloc] init];
        remainkeyVal_dict = [[NSMutableDictionary alloc] init];
        web_Loaded = NO;
        web = [[UIWebView alloc] init];
        web.delegate = self;
        web.layer.cornerRadius = 5.0f;
        web.layer.borderColor = [[UIColor grayColor] CGColor];
        web.layer.borderWidth = 4.0f;
        [main_View.view addSubview:web];

        if (devMode) {
            [self drawWebFrame:web];
        } else {
            web.frame = CGRectMake(10, 10, 1, 1);
        }

        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"settings"] != nil) {
            // nada??
        } else {
            [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"settings"];
        }

        web.hidden = YES;
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

        keyVal_dict = [[NSMutableDictionary alloc] initWithDictionary:[self getKeyValueDictionary:[self readStringFromKeyValueFile]]];

        if ([[keyVal_dict allKeys] count] > 1) {
            numberOfRunningRequests = -1;
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            BlueKai_Reachability *networkReachability = [BlueKai_Reachability reachabilityForInternetConnection];
            NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
            if (networkStatus != NotReachable) {
                web_Loaded = YES;
                web.tag = 1;
                [self startDataUpload];
            } else {
                alertShowBool = YES;
                [self webView:nil didFailLoadWithError:nil];
            }
        }
    }
    return self;
}

- (id)init {
    if (self = [super init]) {
        appVersion = nil;
        devMode = FALSE;
        main_View = nil;
        siteId = nil;
    }

    return self;
}

- (void)setDevMode:(BOOL)mode {
    devMode = mode;

    if (main_View != nil && siteId != nil && appVersion != nil) {
        [self resume];
    }
}

- (void)setAppVersion:(NSString *)version {
    appVersion = version;

    if (main_View != nil && siteId != nil) {
        [self resume];
    }
}

- (void)setViewController:(UIViewController *)view {
    main_View = view;

    if (siteId != nil) {
        web = nil;
        cncl_Btn = nil;

        if (web_URL == nil) {
            web_URL = [[NSMutableString alloc] init];
        } else {
            [web_URL replaceCharactersInRange:NSMakeRange(0, [web_URL length]) withString:@""];
        }

        web = [[UIWebView alloc] init];
        web.delegate = self;
        web.layer.cornerRadius = 5.0f;
        web.layer.borderColor = [[UIColor grayColor] CGColor];
        web.layer.borderWidth = 4.0f;
        [main_View.view addSubview:web];

        if(devMode) {
            [self drawWebFrame:web];
        } else {
            web.frame = CGRectMake(1, 1, 1, 1);
        }

        web.hidden = YES;
        [self resume];
    }
}

- (void)setSiteId:(int)siteid {
    siteId = [NSString stringWithFormat:@"%d", siteid];

    if (main_View != nil) {
        [self resume];
    }
}

- (void)put:(NSString *)key withValue:(NSString *)value {
    if (!web_Loaded) {
        if (web_URL == nil) {
            web_URL = [[NSMutableString alloc] init];
        } else {
            [web_URL replaceCharactersInRange:NSMakeRange(0, [web_URL length]) withString:@""];
        }

        key_str = nil;
        value_str = nil;
        key_str = [key copy];
        value_str = [value copy];

        //Check the settings page to find the use data is allowed to send to server or not
        if (keyVal_dict != nil) {
            [keyVal_dict removeAllObjects];
        } else {
            keyVal_dict = [[NSMutableDictionary alloc] init];
        }

        [keyVal_dict setValue:value_str forKey:key_str];

        NSString *user_value = [[NSUserDefaults standardUserDefaults] objectForKey:@"settings"];

        if ([user_value isEqualToString:@"YES"]) {
            numberOfRunningRequests = -1;
            web_Loaded = YES;

            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            BlueKai_Reachability *networkReachability = [BlueKai_Reachability reachabilityForInternetConnection];
            NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];

            if (networkStatus != NotReachable) {
                [self startDataUpload];
            } else {
                [self webView:nil didFailLoadWithError:nil];
            }

        } else {
            if (!web.hidden) {
                web.hidden = YES;
            }
        }
    } else {
        [nonLoadkeyVal_dict setValue:value forKey:key];
    }

}

- (void)updateWebview:(NSString *)url {
    [web loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if (numberOfRunningRequests != 0) {
        numberOfRunningRequests = 0;

        // to avoid the "Weak receiver may be unpredictably null in ARC mode" warning
        id <OnDataPostedListener> localDelegate = delegate;

        if ([localDelegate respondsToSelector:@selector(onDataPosted:)]) {
            [localDelegate onDataPosted:FALSE];
        }

        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

        //Database *db_Obj=[[Database alloc]init];
        // int flag=1;
        for (int i = 0; i < [[keyVal_dict allKeys] count]; i++) {
            if (![remainkeyVal_dict valueForKey:[keyVal_dict allKeys][i]]) {
                //int attempts=[db_Obj checkForAttempts:[[keyVal_dict allKeys] objectAtIndex:i]:[keyVal_dict valueForKey:[[keyVal_dict allKeys] objectAtIndex:i]]];
                NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithDictionary:[self getKeyValueDictionary:[self readStringFromKeyValueFile]]];
                NSMutableDictionary *atmt_dictionary = [[NSMutableDictionary alloc] initWithDictionary:[self getAttempsDictionary:[self readStringFromAttemptsFile]]];
                int attempts = [atmt_dictionary[[keyVal_dict allKeys][i]] intValue];

                if (attempts == 0) {
                    dictionary[[keyVal_dict allKeys][i]] = [keyVal_dict valueForKey:[keyVal_dict allKeys][i]];
                    atmt_dictionary[[keyVal_dict allKeys][i]] = @"1";
                    // [self writeStringToFile:[self createjson:dictionary]];
                    //[db_Obj insertUserDetails:[[keyVal_dict allKeys] objectAtIndex:i]:[keyVal_dict valueForKey:[[keyVal_dict allKeys] objectAtIndex:i]]:flag:1];
                } else {
                    //NSLog(@"%d",attempts);
                    if (attempts < 5) {
                        [atmt_dictionary removeObjectForKey:[keyVal_dict allKeys][i]];
                        atmt_dictionary[[keyVal_dict allKeys][i]] = [NSString stringWithFormat:@"%d", attempts + 1];
                        //[self writeStringToFile:[self createjson:dictionary]];
                        //[db_Obj updateUserDetails:[[keyVal_dict allKeys] objectAtIndex:i]:[keyVal_dict valueForKey:[[keyVal_dict allKeys] objectAtIndex:i]]:attempts+1];
                    } else {
                        [dictionary removeObjectForKey:[keyVal_dict allKeys][i]];
                        [atmt_dictionary removeObjectForKey:[keyVal_dict allKeys][i]];
                        //[db_Obj deleteKeyValue:[[keyVal_dict allKeys] objectAtIndex:i]:[keyVal_dict valueForKey:[[keyVal_dict allKeys] objectAtIndex:i]]];
                    }
                }

                [self writeStringToKeyValueFile:[self getKeyValueJSON:dictionary]];
                [self writeStringToAttemptsFile:[self getAttemptsJSON:atmt_dictionary]];
            }
        }

        web_Loaded = NO;

        if (remainkeyVal_dict != nil || nonLoadkeyVal_dict != nil) {
            if ([remainkeyVal_dict count] != 0 || [nonLoadkeyVal_dict count] != 0) {
                [self loadAnotherRequest];
            }
        }
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    if (numberOfRunningRequests == 0) {
        numberOfRunningRequests = numberOfRunningRequests + 1;
    } else {
        if (numberOfRunningRequests == -1) {
            numberOfRunningRequests = 0;
            numberOfRunningRequests = numberOfRunningRequests + 1;
        } else {
            numberOfRunningRequests = numberOfRunningRequests + 1;
        }
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    numberOfRunningRequests = numberOfRunningRequests - 1;
    // to avoid the "Weak receiver may be unpredictably null in ARC mode" warning
    id <OnDataPostedListener> localDelegate = delegate;

    if (numberOfRunningRequests == 0) {
        if (!alertShowBool) {
            // Database *dbvalue=[[Database alloc]init];
            if (web.tag == 1) {
                //Delete the key and value pairs from database after sent to server.
                for (int k = 0; k < [keyVal_dict count]; k++) {
                    if (![remainkeyVal_dict valueForKey:[keyVal_dict allKeys][k]]) {
                        // int attempts=[dbvalue checkForAttempts:[[keyVal_dict allKeys] objectAtIndex:k]:[keyVal_dict valueForKey:[[keyVal_dict allKeys] objectAtIndex:k]]];
                        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithDictionary:[self getKeyValueDictionary:[self readStringFromKeyValueFile]]];
                        NSMutableDictionary *atmt_dictionary = [[NSMutableDictionary alloc] initWithDictionary:[self getAttempsDictionary:[self readStringFromAttemptsFile]]];
                        int attempts = [atmt_dictionary[[keyVal_dict allKeys][k]] intValue];

                        if (attempts != 0) {
                            [dictionary removeObjectForKey:[keyVal_dict allKeys][k]];
                            [atmt_dictionary removeObjectForKey:[keyVal_dict allKeys][k]];
                            [self writeStringToKeyValueFile:[self getKeyValueJSON:dictionary]];
                            [self writeStringToAttemptsFile:[self getAttemptsJSON:atmt_dictionary]];
                            //[dbvalue deleteKeyValue:[[keyVal_dict allKeys] objectAtIndex:k]:[keyVal_dict valueForKey:[[keyVal_dict allKeys] objectAtIndex:k]]];
                            // NSLog(@"Database Data deleted");
                        }
                    }
                }
            }

            if (devMode) {
                web.hidden = NO;
                cncl_Btn.hidden = NO;
            }

            web_Loaded = NO;
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

            if ([localDelegate respondsToSelector:@selector(onDataPosted:)]) {
                [localDelegate onDataPosted:TRUE];
            }

            // NSLog(@"Passed %@",webView.request.URL);
            alertShowBool = YES;

            if (remainkeyVal_dict != nil || nonLoadkeyVal_dict != nil) {
                if ([remainkeyVal_dict count] != 0 || [nonLoadkeyVal_dict count] != 0) {
                    [self loadAnotherRequest];
                }
            }

            NSArray *webviews = [main_View.view subviews];
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
                                }
                                else {
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
    if ([remainkeyVal_dict count] == 0) {
        if ([nonLoadkeyVal_dict count] != 0) {
            web = [[UIWebView alloc] init];
            web.delegate = self;
            web.layer.cornerRadius = 5.0f;
            web.layer.borderColor = [[UIColor grayColor] CGColor];
            web.layer.borderWidth = 4.0f;
            web.hidden = YES;
            [main_View.view addSubview:web];

            if (devMode) {
                [self drawWebFrame:web];
            } else {
                web.frame = CGRectMake(10, 10, 1, 1);
            }

            web_Loaded = NO;

            if (keyVal_dict != nil) {
                [keyVal_dict removeAllObjects];
            } else {
                keyVal_dict = [[NSMutableDictionary alloc] init];
            }

            numberOfRunningRequests = -1;

            if (web_URL == nil) {
                web_URL = [[NSMutableString alloc] init];
            } else {
                [web_URL replaceCharactersInRange:NSMakeRange(0, [web_URL length]) withString:@""];
            }

            //Code to send the multiple values for every request.

            for (int i = 0; i < [[nonLoadkeyVal_dict allKeys] count]; i++) {
                NSString *key = [NSString stringWithFormat:@"%@", [nonLoadkeyVal_dict allKeys][i]];
                NSString *value = [NSString stringWithFormat:@"%@", nonLoadkeyVal_dict[[nonLoadkeyVal_dict allKeys][i]]];

                if ((urlStringCount + key.length + value.length + 2) <= 255) {
                    [keyVal_dict setValue:[nonLoadkeyVal_dict valueForKey:[nonLoadkeyVal_dict allKeys][i]] forKey:[nonLoadkeyVal_dict allKeys][i]];
                    urlStringCount = urlStringCount + key.length + value.length + 2;
                }
            }

            for (int j = 0; j < [[keyVal_dict allKeys] count]; j++) {
                [nonLoadkeyVal_dict removeObjectForKey:[keyVal_dict allKeys][j]];
            }

            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            [self startDataUpload];
        } else {
            nonLoadkeyVal_dict = nil;
            remainkeyVal_dict = nil;
            keyVal_dict = nil;
            web_URL = nil;
        }
    } else {
        web = [[UIWebView alloc] init];
        web.delegate = self;
        web.layer.cornerRadius = 5.0f;
        web.layer.borderColor = [[UIColor grayColor] CGColor];
        web.layer.borderWidth = 4.0f;
        web.tag = 1;
        web.hidden = YES;
        [main_View.view addSubview:web];

        if (devMode) {
            [self drawWebFrame:web];
        } else {
            web.frame = CGRectMake(10, 10, 1, 1);
        }

        if (keyVal_dict != nil) {
            [keyVal_dict removeAllObjects];
        } else {
            keyVal_dict = [[NSMutableDictionary alloc] init];
        }

        [keyVal_dict setValuesForKeysWithDictionary:remainkeyVal_dict];

        if (web_URL == nil) {
            web_URL = [[NSMutableString alloc] init];
        } else {
            [web_URL replaceCharactersInRange:NSMakeRange(0, [web_URL length]) withString:@""];
        }

        numberOfRunningRequests = -1;
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        [self startDataUpload];
    }
}

- (void)put:(NSDictionary *)dictionary {
    if (web_URL == nil) {
        web_URL = [[NSMutableString alloc] init];
    }
    else {
        [web_URL replaceCharactersInRange:NSMakeRange(0, [web_URL length]) withString:@""];
    }

    if (keyVal_dict != nil) {
        [keyVal_dict removeAllObjects];
    } else {
        keyVal_dict = [[NSMutableDictionary alloc] init];
    }

    [keyVal_dict setValuesForKeysWithDictionary:dictionary];

    //Check the settings page to find the use data is allowed to send to server or not
    // Database *db_Obj=[[Database alloc]init];

    NSString *value = [[NSUserDefaults standardUserDefaults] objectForKey:@"settings"];

    if ([value isEqualToString:@"YES"]) {
        numberOfRunningRequests = -1;
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        BlueKai_Reachability *networkReachability = [BlueKai_Reachability reachabilityForInternetConnection];
        NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];

        if (networkStatus != NotReachable) {
            [self startDataUpload];
        } else {
            [self webView:nil didFailLoadWithError:nil];
        }
    } else {
        if (!web.hidden) {
            web.hidden = YES;
        }
    }
}

- (void)startBackgroundJob:(NSDictionary *)dictionary {
    if (remainkeyVal_dict != nil) {
        [remainkeyVal_dict removeAllObjects];
    }

    @autoreleasepool {
        //send the dictionnary details to bluekai server
        NSMutableString *url_string = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"%@?site=%@&", server_URL, siteId]];
        [url_string appendString:[NSString stringWithFormat:@"appVersion=%@", appVersion]];
        [url_string appendString:[NSString stringWithFormat:@"&identifierForVendor=%@", [NSString stringWithFormat:@"%@", [self getVendorID]]]];
        urlStringCount = url_string.length;

        for (int i = 0; i < [[keyVal_dict allKeys] count]; i++) {
            NSString *key = [NSString stringWithFormat:@"%@", [keyVal_dict allKeys][i]];
            NSString *value = [NSString stringWithFormat:@"%@", keyVal_dict[[keyVal_dict allKeys][i]]];

            if ((url_string.length + key.length + value.length + 2) > 255) {
                [remainkeyVal_dict setValue:value forKey:key];
            } else {
                [url_string appendString:[NSString stringWithFormat:@"&%@=%@", [self urlEncode:[keyVal_dict allKeys][i]], [self urlEncode:keyVal_dict[[keyVal_dict allKeys][i]]]]];
            }
        }
        // NSString *encode_String=[url_string urlencode];
        NSLog(@"Encoded Url:%@", url_string);
        [web_URL appendString:url_string];
    }
    alertShowBool = NO;

    // web.tag=1;
    [self updateWebview:web_URL];
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

- (void)showSettingsScreen {
    //    NSArray *array=[main_View.view subviews];
    //    for (UIView *view in array) {
    //        if(![view isKindOfClass:[UIWebView class]])
    //        {
    //            [view removeFromSuperview];
    //        }
    //    }
    user_defaults = [NSUserDefaults standardUserDefaults];
    usrcheck_image = [[UIImageView alloc] initWithFrame:CGRectMake(25, 100, 40, 40)];
    checkimage = @[@"chk-1.png", @"unchk-1.png"];

    UIGraphicsBeginImageContext(usrcheck_image.frame.size);
    //  Database *db=[[Database alloc]init];
    // NSDictionary *dictionary=[[NSDictionary alloc]initWithDictionary:[self createDictionary:[self readStringFromFile]]];
    NSString *value = [[NSUserDefaults standardUserDefaults] objectForKey:@"settings"];

    if ([value isEqualToString:@"YES"]) {
        [[UIImage imageNamed:@"chk-1.png"] drawInRect:usrcheck_image.bounds];
        [user_defaults setObject:@"YES" forKey:@"KeyTouserData"];
        usrcheck_image.tag = 0;
    } else {
        [[UIImage imageNamed:@"unchk-1.png"] drawInRect:usrcheck_image.bounds];
        [user_defaults setObject:@"NO" forKey:@"KeyTouserData"];
        usrcheck_image.tag = 1;
    }

    UIImage *lblimage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    usrcheck_image.image = lblimage;
    usrcheck_image.userInteractionEnabled = YES;
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userData_Change:)];
    tap.delegate = self;
    [usrcheck_image addGestureRecognizer:tap];
    [main_View.view addSubview:usrcheck_image];

    UILabel *usrData_lbl = [[UILabel alloc] initWithFrame:CGRectMake(75, 95, 240, 50)];
    usrData_lbl.textColor = [UIColor blackColor];
    usrData_lbl.backgroundColor = [UIColor clearColor];
    usrData_lbl.textAlignment = NSTextAlignmentLeft;
    usrData_lbl.numberOfLines = 0;
    usrData_lbl.lineBreakMode = NSLineBreakByWordWrapping;
    usrData_lbl.font = [UIFont systemFontOfSize:14];
    usrData_lbl.text = @"Allow Bluekai to receive my data";
    [main_View.view addSubview:usrData_lbl];

    UILabel *tclbl = [[UILabel alloc] initWithFrame:CGRectMake(25, 235, 280, 50)];
    tclbl.textColor = [UIColor blackColor];
    tclbl.backgroundColor = [UIColor clearColor];
    tclbl.textAlignment = NSTextAlignmentLeft;
    tclbl.numberOfLines = 3;
    tclbl.lineBreakMode = NSLineBreakByWordWrapping;
    tclbl.font = [UIFont systemFontOfSize:14];
    tclbl.text = @"The BlueKai privacy policy is available";
    [main_View.view addSubview:tclbl];

    UIButton *Here = [UIButton buttonWithType:UIButtonTypeCustom];
    Here.frame = CGRectMake(256, 253, 50, 14);
    [Here setTitle:@"here" forState:UIControlStateNormal];
    Here.titleLabel.font = [UIFont systemFontOfSize:14];
    [Here addTarget:self action:@selector(termsConditions:) forControlEvents:UIControlEventTouchUpInside];
    [Here setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [main_View.view addSubview:Here];

    UIButton *savebtn = [UIButton buttonWithType:UIButtonTypeCustom];
    savebtn.frame = CGRectMake(75, 290, 80, 35);
    [savebtn setTitle:@"Save" forState:UIControlStateNormal];
    [savebtn.layer setBorderWidth:2.0f];
    [savebtn.layer setBorderColor:[[UIColor grayColor] CGColor]];
    [savebtn.layer setCornerRadius:5.0f];
    [savebtn addTarget:self action:@selector(saveSettings:) forControlEvents:UIControlEventTouchUpInside];
    [savebtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [main_View.view addSubview:savebtn];

    UIButton *Cnclbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    Cnclbtn.frame = CGRectMake(175, 290, 80, 35);
    [Cnclbtn setTitle:@"Cancel" forState:UIControlStateNormal];
    [Cnclbtn.layer setBorderWidth:2.0f];
    [Cnclbtn.layer setBorderColor:[[UIColor grayColor] CGColor]];
    [Cnclbtn.layer setCornerRadius:5.0f];
    [Cnclbtn addTarget:self action:@selector(Cancelbtn:) forControlEvents:UIControlEventTouchUpInside];
    [Cnclbtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [main_View.view addSubview:Cnclbtn];
    [main_View.view addSubview:web];
    [main_View.view addSubview:cncl_Btn];
}

- (void)userData_Change:(UITapGestureRecognizer *)recognizer {
    if (usrcheck_image.tag == 1) {
        UIGraphicsBeginImageContext(usrcheck_image.frame.size);
        [[UIImage imageNamed:@"chk-1.png"] drawInRect:usrcheck_image.bounds];
        UIImage *appsimage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        usrcheck_image.image = appsimage;
        [user_defaults setObject:@"YES" forKey:@"KeyTouserData"];
        usrcheck_image.tag = 0;
    } else {
        UIGraphicsBeginImageContext(usrcheck_image.frame.size);
        [[UIImage imageNamed:@"unchk-1.png"] drawInRect:usrcheck_image.bounds];
        UIImage *appsimage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        usrcheck_image.image = appsimage;
        [user_defaults setObject:@"NO" forKey:@"KeyTouserData"];
        usrcheck_image.tag = 1;
    }

}

- (IBAction)termsConditions:(id)sender {
    NSString *shareUrlString = [NSString stringWithFormat:@"http://www.bluekai.com/consumers_privacyguidelines.php"];

    NSURL *Hereurl = [[NSURL alloc] initWithString:shareUrlString];
    //Create the URL object

    [[UIApplication sharedApplication] openURL:Hereurl];
    //Launch Safari with the URL you created

}

- (IBAction)Cancelbtn:(id)sender {

}

- (IBAction)Cancel:(id)sender {
    web.hidden = YES;
    cncl_Btn.hidden = YES;
}

- (void)setPreference:(BOOL)optIn {
    user_defaults = [NSUserDefaults standardUserDefaults];

    if (optIn) {
        [user_defaults setObject:@"YES" forKey:@"KeyTouserData"];
    } else {
        [user_defaults setObject:@"NO" forKey:@"KeyTouserData"];
    }

    [self saveSettings:nil];
    [self updateServer];
}

- (IBAction)saveSettings:(id)sender {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSString *userDataValue = [user_defaults objectForKey:@"KeyTouserData"];
    [[NSUserDefaults standardUserDefaults] setObject:userDataValue forKey:@"settings"];
    //    Database *dbvalue=[[Database alloc]init];
    //
    //    [dbvalue deleteUserData];
    //    [dbvalue insertUserDataValue:userDataValue];
    [self updateServer];
}

- (void)updateServer {
    //web_URL=nil;
    if (web_URL == nil) {
        web_URL = [[NSMutableString alloc] init];
    } else {
        [web_URL replaceCharactersInRange:NSMakeRange(0, [web_URL length]) withString:@""];
    }

    keyVal_dict = [[NSMutableDictionary alloc] init];

    if ([[user_defaults objectForKey:@"KeyTouserData"] isEqualToString:@"YES"]) {
        value_str = @"1";
    } else {
        value_str = @"0";
    }

    [keyVal_dict setValue:value_str forKey:[NSString stringWithFormat:@"TC"]];
    numberOfRunningRequests = -1;
    BlueKai_Reachability *networkReachability = [BlueKai_Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];

    if (networkStatus != NotReachable) {
        [self startDataUpload];
    } else {
        [self webView:nil didFailLoadWithError:nil];
    }
}

- (void)startDataUpload {
    // Database *db_Obj=[[Database alloc]init];
    // int flag=1;
    if (main_View != nil) {
        if (siteId != nil) {
            if (appVersion != nil) {
                [NSThread detachNewThreadSelector:@selector(startBackgroundJob:) toTarget:self withObject:keyVal_dict];
            } else {
                NSLog(@"appVersion parameter is nil");

                for (int i = 0; i < [[keyVal_dict allKeys] count]; i++) {
                    if (![remainkeyVal_dict valueForKey:[keyVal_dict allKeys][i]]) {
                        //int attempts=[db_Obj checkForAttempts:[[keyVal_dict allKeys] objectAtIndex:i]:[keyVal_dict valueForKey:[[keyVal_dict allKeys] objectAtIndex:i]]];
                        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithDictionary:[self getKeyValueDictionary:[self readStringFromKeyValueFile]]];
                        NSMutableDictionary *atmt_dictionary = [[NSMutableDictionary alloc] initWithDictionary:[self getAttempsDictionary:[self readStringFromAttemptsFile]]];
                        int attempts = [atmt_dictionary[[keyVal_dict allKeys][i]] intValue];

                        if (attempts == 0) {
                            dictionary[[keyVal_dict allKeys][i]] = [keyVal_dict valueForKey:[keyVal_dict allKeys][i]];
                            atmt_dictionary[[keyVal_dict allKeys][i]] = @"1";
                            // [self writeStringToFile:[self createjson:dictionary]];
                            //[db_Obj insertUserDetails:[[keyVal_dict allKeys] objectAtIndex:i]:[keyVal_dict valueForKey:[[keyVal_dict allKeys] objectAtIndex:i]]:flag:1];
                        } else {
                            //NSLog(@"%d",attempts);
                            if (attempts < 5) {
                                [atmt_dictionary removeObjectForKey:[keyVal_dict allKeys][i]];
                                atmt_dictionary[[keyVal_dict allKeys][i]] = [NSString stringWithFormat:@"%d", attempts + 1];
                                //[self writeStringToFile:[self createjson:dictionary]];
                                //[db_Obj updateUserDetails:[[keyVal_dict allKeys] objectAtIndex:i]:[keyVal_dict valueForKey:[[keyVal_dict allKeys] objectAtIndex:i]]:attempts+1];
                            } else {
                                [dictionary removeObjectForKey:[keyVal_dict allKeys][i]];
                                [atmt_dictionary removeObjectForKey:[keyVal_dict allKeys][i]];
                                //[db_Obj deleteKeyValue:[[keyVal_dict allKeys] objectAtIndex:i]:[keyVal_dict valueForKey:[[keyVal_dict allKeys] objectAtIndex:i]]];
                            }
                        }

                        [self writeStringToKeyValueFile:[self getKeyValueJSON:dictionary]];
                        [self writeStringToAttemptsFile:[self getAttemptsJSON:atmt_dictionary]];
                    }
                }

                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            }
        } else {
            if (appVersion != nil) {
                NSLog(@"siteId parameter is nil");
            } else {
                NSLog(@"siteId and appVersion parameters are nil");
            }

            for (int i = 0; i < [[keyVal_dict allKeys] count]; i++) {
                if (![remainkeyVal_dict valueForKey:[keyVal_dict allKeys][i]]) {
                    //int attempts=[db_Obj checkForAttempts:[[keyVal_dict allKeys] objectAtIndex:i]:[keyVal_dict valueForKey:[[keyVal_dict allKeys] objectAtIndex:i]]];
                    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithDictionary:[self getKeyValueDictionary:[self readStringFromKeyValueFile]]];
                    NSMutableDictionary *atmt_dictionary = [[NSMutableDictionary alloc] initWithDictionary:[self getAttempsDictionary:[self readStringFromAttemptsFile]]];
                    int attempts = [atmt_dictionary[[keyVal_dict allKeys][i]] intValue];
                    if (attempts == 0) {
                        dictionary[[keyVal_dict allKeys][i]] = [keyVal_dict valueForKey:[keyVal_dict allKeys][i]];
                        atmt_dictionary[[keyVal_dict allKeys][i]] = @"1";
                        // [self writeStringToFile:[self createjson:dictionary]];
                        //[db_Obj insertUserDetails:[[keyVal_dict allKeys] objectAtIndex:i]:[keyVal_dict valueForKey:[[keyVal_dict allKeys] objectAtIndex:i]]:flag:1];
                    } else {
                        //NSLog(@"%d",attempts);
                        if (attempts < 5) {
                            [atmt_dictionary removeObjectForKey:[keyVal_dict allKeys][i]];
                            atmt_dictionary[[keyVal_dict allKeys][i]] = [NSString stringWithFormat:@"%d", attempts + 1];
                            //[self writeStringToFile:[self createjson:dictionary]];
                            //[db_Obj updateUserDetails:[[keyVal_dict allKeys] objectAtIndex:i]:[keyVal_dict valueForKey:[[keyVal_dict allKeys] objectAtIndex:i]]:attempts+1];
                        } else {
                            [dictionary removeObjectForKey:[keyVal_dict allKeys][i]];
                            [atmt_dictionary removeObjectForKey:[keyVal_dict allKeys][i]];
                            //[db_Obj deleteKeyValue:[[keyVal_dict allKeys] objectAtIndex:i]:[keyVal_dict valueForKey:[[keyVal_dict allKeys] objectAtIndex:i]]];
                        }
                    }

                    [self writeStringToKeyValueFile:[self getKeyValueJSON:dictionary]];
                    [self writeStringToAttemptsFile:[self getAttemptsJSON:atmt_dictionary]];
                }
            }

            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        }
    } else {
        if (siteId != nil && appVersion != nil) {
            NSLog(@"view parameter is nil");
        } else {
            if (siteId != nil) {
                if (appVersion != nil) {
                    NSLog(@"view parameter is nil");
                } else {
                    NSLog(@"view and appVersion parameters are nil");
                }
            } else {
                if (appVersion != nil) {
                    NSLog(@"siteId and view parameters are nil");
                } else {
                    NSLog(@"siteId,view and appVersion parameters are nil");
                }
            }
        }
        // int flag=1;
        for (int i = 0; i < [[keyVal_dict allKeys] count]; i++) {
            if (![remainkeyVal_dict valueForKey:[keyVal_dict allKeys][i]]) {
                //int attempts=[db_Obj checkForAttempts:[[keyVal_dict allKeys] objectAtIndex:i]:[keyVal_dict valueForKey:[[keyVal_dict allKeys] objectAtIndex:i]]];
                NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithDictionary:[self getKeyValueDictionary:[self readStringFromKeyValueFile]]];
                NSMutableDictionary *atmt_dictionary = [[NSMutableDictionary alloc] initWithDictionary:[self getAttempsDictionary:[self readStringFromAttemptsFile]]];
                int attempts = [atmt_dictionary[[keyVal_dict allKeys][i]] intValue];

                if (attempts == 0) {
                    dictionary[[keyVal_dict allKeys][i]] = [keyVal_dict valueForKey:[keyVal_dict allKeys][i]];
                    atmt_dictionary[[keyVal_dict allKeys][i]] = @"1";
                    // [self writeStringToFile:[self createjson:dictionary]];
                    //[db_Obj insertUserDetails:[[keyVal_dict allKeys] objectAtIndex:i]:[keyVal_dict valueForKey:[[keyVal_dict allKeys] objectAtIndex:i]]:flag:1];
                } else {
                    //NSLog(@"%d",attempts);
                    if (attempts < 5) {
                        [atmt_dictionary removeObjectForKey:[keyVal_dict allKeys][i]];
                        atmt_dictionary[[keyVal_dict allKeys][i]] = [NSString stringWithFormat:@"%d", attempts + 1];
                        //[self writeStringToFile:[self createjson:dictionary]];
                        //[db_Obj updateUserDetails:[[keyVal_dict allKeys] objectAtIndex:i]:[keyVal_dict valueForKey:[[keyVal_dict allKeys] objectAtIndex:i]]:attempts+1];
                    } else {
                        [dictionary removeObjectForKey:[keyVal_dict allKeys][i]];
                        [atmt_dictionary removeObjectForKey:[keyVal_dict allKeys][i]];
                        //[db_Obj deleteKeyValue:[[keyVal_dict allKeys] objectAtIndex:i]:[keyVal_dict valueForKey:[[keyVal_dict allKeys] objectAtIndex:i]]];
                    }
                }

                [self writeStringToKeyValueFile:[self getKeyValueJSON:dictionary]];
                [self writeStringToAttemptsFile:[self getAttemptsJSON:atmt_dictionary]];
            }
        }

        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
}

- (void)resume {
    if (web_URL == nil) {
        web_URL = [[NSMutableString alloc] init];
    } else {
        [web_URL replaceCharactersInRange:NSMakeRange(0, [web_URL length]) withString:@""];
    }

    keyVal_dict = [[NSMutableDictionary alloc] initWithDictionary:[self getKeyValueDictionary:[self readStringFromKeyValueFile]]];

    if ([[keyVal_dict allKeys] count] != 0) {
        numberOfRunningRequests = -1;
        BlueKai_Reachability *networkReachability = [BlueKai_Reachability reachabilityForInternetConnection];
        NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];

        if (networkStatus != NotReachable) {
            web.tag = 1;
            [self startDataUpload];
        } else {
            [self webView:nil didFailLoadWithError:nil];
        }

    }
}

- (void)drawWebFrame:(UIWebView *)web {
    web.frame = CGRectMake(10, 10, 300, 390);
    cncl_Btn = [UIButton buttonWithType:UIButtonTypeCustom];
    cncl_Btn.frame = CGRectMake(281, 9, 30, 30);
    cncl_Btn.tag = 10;
    [cncl_Btn setImage:[UIImage imageNamed:@"btn-sub-del-op.png"] forState:UIControlStateNormal];
    [cncl_Btn addTarget:self action:@selector(Cancel:) forControlEvents:UIControlEventTouchUpInside];
    cncl_Btn.hidden = YES;
    [main_View.view addSubview:cncl_Btn];
}

@end
