//
//  BlueKaiTestCase.m
//  Bluekai_SDK
//
//  Created by Shun Chu on 5/16/14.
//  Copyright (c) 2014 BlueKai. All rights reserved.
//
// Mocking objects: https://github.com/jonreid/OCMockito
// Object matcher: https://github.com/specta/expecta
// HTTP request testing: https://github.com/luisobo/Nocilla


#import <XCTest/XCTest.h>
#import "BlueKai.h"


// Class extension to make private methods available to test
@interface BlueKai ()
// Testable private methods
- (void)writeStringToKeyValueFile:(NSString *)aString;
- (NSString *)readStringFromKeyValueFile;
- (NSString *)getKeyValueJSON:(NSMutableDictionary *)keyValues;
- (NSDictionary *)getKeyValueDictionary:(NSString *)jsonString;
- (void)writeStringToAttemptsFile:(NSString *)aString;
- (NSString *)readStringFromAttemptsFile;
- (NSString *)getAttemptsJSON:(NSMutableDictionary *)keyValues;
- (NSDictionary *)getAttemptsDictionary:(NSString *)jsonString;
- (void)saveOptInPrefsOnServer;
- (void)loadAnotherRequest;
- (NSString *)urlEncode:(NSString *)string;
- (void)userDataChanged:(UITapGestureRecognizer *)recognizer;
- (void)startDataUpload;
- (void)startBackgroundJob:(NSDictionary *)dictionary;
- (void)uploadIfNetworkIsAvailable;
- (NSMutableString *)constructUrl;
- (void)blueKaiLogger:(BOOL)devMode withString:(NSString *)string withObject:(NSObject *)object;
@end


// Actual tests
@interface BlueKaiTestCase : XCTestCase {
    BlueKai  *blueKaiSdk;
    BOOL     devMode;

    NSMutableDictionary *keyValsDictionary;
    NSString *appVersion,
             *idfa,
             *expected,
             *myKey1,
             *myKey2,
             *myValue1,
             *myValue2,
             *siteId;
    UIViewController *viewController;
}
@end

@implementation BlueKaiTestCase

- (void)setUp
{
    [super setUp];
//    NSLog(@"##### %s", __PRETTY_FUNCTION__);

    appVersion = @"1.0.0";
    devMode = YES;
    idfa = @"123ABC";
    siteId = @"2";
    viewController = [[UIViewController alloc] init];

    myKey1 = @"myKey1";
    myKey2 = @"myKey2";
    myValue1 = @"myValue1";
    myValue2 = @"myValue2";
    expected = [NSString stringWithFormat: @"{\"%@\":\"%@\",\"%@\":\"%@\"}", myKey2, myValue2, myKey1, myValue1];
    keyValsDictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:myValue1, myKey1, myValue2, myKey2, nil];

    blueKaiSdk = [[BlueKai alloc] initWithSiteId:siteId
                                  withAppVersion:appVersion
                                        withIdfa:idfa
                                        withView:viewController
                                     withDevMode:devMode];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
//    NSLog(@"##### %s", __PRETTY_FUNCTION__);
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testDesignatedInitMethod
{
    XCTAssertNotNil(blueKaiSdk, @"Object is not nil");
    XCTAssertTrue([[blueKaiSdk appVersion] isEqualToString:appVersion], @"appVersion should be set");
    XCTAssertTrue([blueKaiSdk devMode], @"devMode should be TRUE");
    XCTAssertTrue([[blueKaiSdk idfa] isEqualToString:idfa], @"idfa should be set");
    XCTAssertTrue([[blueKaiSdk siteId] isEqualToString:siteId], @"siteId should be set");
    XCTAssertNotNil([blueKaiSdk viewController], @"viewController should not be nil");
}

- (void)testBasicInitMethod
{
    BlueKai *basicBlueKaiSdk = [[BlueKai alloc] initWithSiteId:siteId
                                                withAppVersion:appVersion
                                                      withView:viewController
                                                   withDevMode:devMode];

    XCTAssertNotNil(basicBlueKaiSdk, @"Object is not nil");
    XCTAssertTrue([[basicBlueKaiSdk appVersion] isEqualToString:appVersion], @"appVersion should be set");
    XCTAssertTrue([basicBlueKaiSdk devMode], @"devMode should be TRUE");
    XCTAssertNil([basicBlueKaiSdk idfa], @"idfa should be nil");
    XCTAssertTrue([[basicBlueKaiSdk siteId] isEqualToString:siteId], @"siteId should be set");
    XCTAssertNotNil([basicBlueKaiSdk viewController], @"viewController should not be nil");
}

- (void)testDeprecatedInitMethod
{
    BlueKai *deprecatedBlueKaiSdk = [[BlueKai alloc] initWithArgs:devMode
                                                       withSiteId:siteId
                                                   withAppVersion:appVersion
                                                         withView:viewController];
    
    XCTAssertNotNil(deprecatedBlueKaiSdk, @"Object is not nil");
    XCTAssertTrue([[deprecatedBlueKaiSdk appVersion] isEqualToString:appVersion], @"appVersion should be set");
    XCTAssertTrue([deprecatedBlueKaiSdk devMode], @"devMode should be TRUE");
    XCTAssertTrue([[deprecatedBlueKaiSdk siteId] isEqualToString:siteId], @"siteId should be set");
    XCTAssertNotNil([deprecatedBlueKaiSdk viewController], @"viewController should not be nil");
}

- (void)testCanSetAppVersion
{
    NSString *newAppVersion = @"2.0.0";
    [blueKaiSdk setAppVersion:newAppVersion];
    XCTAssertTrue([[blueKaiSdk appVersion] isEqualToString:newAppVersion], @"new appVersion was not set");
}

- (void)testCanSetDevMode
{
    [blueKaiSdk setDevMode:NO];
    XCTAssertFalse([blueKaiSdk devMode], @"new devMode was not set");
}

- (void)testCanSetIdfa
{
    NSString *newIdfa = @"123abc";
    [blueKaiSdk setIdfa:newIdfa];
    XCTAssertTrue([[blueKaiSdk idfa] isEqualToString:newIdfa], @"IDFA strings was not set");
}

- (void)testCanSetOptInPreference
{
    [blueKaiSdk setOptInPreference:NO];
    XCTAssertFalse([blueKaiSdk optInPreference], @"new optInPreference was not set");
}

- (void)testCanSetSiteId
{
    NSString *newSiteId = @"5";
    [blueKaiSdk setSiteId:newSiteId];
    XCTAssertTrue([[blueKaiSdk siteId] isEqualToString:newSiteId], @"new siteId was not set");
}

- (void)testHttpsDefaultsToNo
{
    XCTAssertFalse([blueKaiSdk useHttps], @"https should default to NO");
}

- (void)testCanSetHttps
{
    [blueKaiSdk setUseHttps:YES];
    XCTAssertTrue([blueKaiSdk useHttps], @"https setting did not change");
}

/*
- (void)testCanUpdateWithKeyAndValue
{
    // requires Nocilla
    stubRequest(@"GET", @"http://mobileproxy.bluekai.com/m.html").andReturn(200);
    [blueKaiSdk setDevMode:YES];
    [blueKaiSdk setOptInPreference:YES];
    [blueKaiSdk updateWithKey:myKey1 andValue:myValue1];
}

- (void)testCanUpdateWithDictionaryParams
{
    // requires Nocilla
    stubRequest(@"GET", @"http://mobileproxy.bluekai.com/m.html").andReturn(200);
    NSDictionary *keyValsDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:myValue1, myKey1,
                                                                                   myValue2, myKey2, nil];
    [blueKaiSdk setDevMode:YES];
    [blueKaiSdk setOptInPreference:YES];
    [blueKaiSdk updateWithDictionary:keyValsDictionary];
}

- (void)testResume
{

}
*/


// Private methods
- (void)testCanWriteStringToKeyValueFile
{
    // set data
    [blueKaiSdk writeStringToKeyValueFile:[blueKaiSdk getKeyValueJSON:keyValsDictionary]];

    // get data
    NSString *filePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    NSString *fileName = @"user_data.bk";
    NSString *fileAtPath = [filePath stringByAppendingPathComponent:fileName];
    NSString *data = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:fileAtPath] encoding:NSUTF8StringEncoding];

    XCTAssertEqualObjects(expected, data, @"Data written to file differ from expected string");
}

- (void)testCanReadStringFromKeyValueFile
{
    // set data
    NSString *filePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    NSString *fileName = @"user_data.bk";
    NSString *fileAtPath = [filePath stringByAppendingPathComponent:fileName];
    [[expected dataUsingEncoding:NSUTF8StringEncoding] writeToFile:fileAtPath atomically:NO];

    XCTAssertEqualObjects(expected, [blueKaiSdk readStringFromKeyValueFile], @"Data read from file differ from expected string");
}

- (void)testCanGetKeyValueJSON
{
    XCTAssertEqualObjects(expected, [blueKaiSdk getKeyValueJSON:keyValsDictionary], @"JSON strings do not match");
}

- (void)testGetKeyValueDictionary
{
    XCTAssertEqualObjects(keyValsDictionary, [blueKaiSdk getKeyValueDictionary:expected], @"Dictionary data differ from expected string");
}

- (void)testWriteStringToAttemptsFile
{
    NSString *attemptsString = @"{\"myKey1\":\"1\",\"myKey2\":\"1\"}";

    // set data
    [blueKaiSdk writeStringToAttemptsFile:attemptsString];

    // read data
    NSString *filePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    NSString *fileName = @"attempts.bk";
    NSString *fileAtPath = [filePath stringByAppendingPathComponent:fileName];

    XCTAssertEqualObjects(attemptsString, [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:fileAtPath] encoding:NSUTF8StringEncoding], @"Attempts strings don't match");
}

- (void)testReadStringFromAttemptsFile
{
    // set data
    NSString *attemptsString = @"{\"myKey1\":\"1\",\"myKey2\":\"1\"}";
    NSString *filePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    NSString *fileName = @"attempts.bk";
    NSString *fileAtPath = [filePath stringByAppendingPathComponent:fileName];
    [[NSFileManager defaultManager] createFileAtPath:fileAtPath contents:nil attributes:nil];
    [[attemptsString dataUsingEncoding:NSUTF8StringEncoding] writeToFile:fileAtPath atomically:NO];

    XCTAssertEqualObjects(attemptsString, [blueKaiSdk readStringFromAttemptsFile], @"Attempts strings don't match");
}

- (void)testGetAttemptsJSON
{
    XCTAssertEqualObjects([blueKaiSdk getAttemptsJSON:keyValsDictionary], expected, @"JSON strings don't match");
}

- (void)testGetAttemptsDictionary
{
    XCTAssertEqualObjects([blueKaiSdk getKeyValueDictionary:expected], keyValsDictionary, @"Dictionary objects don't match");
}

// not required until BKSID opt-out is implemented
/*- (void)testSaveOptInPrefsOnServer
{

}*/

// not sure how to test this yet; method probably not even needed
/*- (void)testLoadAnotherRequest
{

}*/

- (void)testUrlEncode
{
    NSString *encodedOutput = [blueKaiSdk urlEncode:@" `~!@#$%^&*()_+-={}[]|\\:;\"'<,>.?/AZaz"];
    NSString *expectedOutput = @"+%60~%21%40%23%24%25%5E%26%2A%28%29_%2B-%3D%7B%7D%5B%5D%7C%5C%3A%3B%22%27%3C%2C%3E.%3F%2FAZaz";
    XCTAssertTrue([expectedOutput isEqualToString:encodedOutput], @"Encoded strings do not match");
}

// not sure if this should be tested
/*- (void)testUserDataChanged
{

}*/


// not sure how to these these yet
/*- (void)testStartDataUpload
{

}

- (void)testStartBackgroundJob
{

}

- (void)testCanUploadIfNetworkIsAvailable {

}*/

- (void)testConstructUrl
{
    BlueKai *bksdk1 = [[BlueKai alloc] initWithSiteId:siteId withAppVersion:appVersion withView:viewController withDevMode:NO];
    NSMutableString *url1 = [bksdk1 constructUrl];
    NSString *expectedUrl1 = [NSString stringWithFormat:@"http://mobileproxy.bluekai.com/m.html?site=%@&appVersion=%@&myKey2=myValue2&myKey1=myValue1", siteId, appVersion];
    XCTAssertTrue([expectedUrl1 isEqualToString:url1], @"URL strings should match");

    BlueKai *bksdk2 = [[BlueKai alloc] initWithSiteId:siteId withAppVersion:appVersion withIdfa:idfa withView:viewController withDevMode:NO];
    NSMutableString *url2 = [bksdk2 constructUrl];
    NSString *expectedUrl2 = [NSString stringWithFormat:@"http://mobileproxy.bluekai.com/m.html?site=%@&appVersion=%@&idfa=%@&myKey2=myValue2&myKey1=myValue1", siteId, appVersion, idfa];
    XCTAssertTrue([expectedUrl2 isEqualToString:url2], @"URL strings should match");

    BlueKai *bksdk3 = [[BlueKai alloc] initWithSiteId:siteId withAppVersion:appVersion withIdfa:idfa withView:viewController withDevMode:YES];
    NSMutableString *url3 = [bksdk3 constructUrl];
    NSString *expectedUrl3 = [NSString stringWithFormat:@"http://mobileproxy.bluekai.com/m-sandbox.html?site=%@&appVersion=%@&idfa=%@&myKey2=myValue2&myKey1=myValue1", siteId, appVersion, idfa];
    XCTAssertTrue([expectedUrl3 isEqualToString:url3], @"URL strings should match");
}

@end
