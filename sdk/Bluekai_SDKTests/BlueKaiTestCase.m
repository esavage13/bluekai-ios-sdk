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

@interface BlueKaiTestCase : XCTestCase{
    BlueKai *blueKaiSdk;
    UIViewController *viewController;
    NSString *siteId;
    NSString *appVersion;
    BOOL devMode;
    UIView *view;
}
@end

@implementation BlueKaiTestCase

- (void)setUp
{
    [super setUp];
    NSLog(@"==>> %s", __PRETTY_FUNCTION__);
    
    viewController = [[UIViewController alloc] init];
    view = [[UIView alloc] init];
    [viewController setView:view];
    siteId = @"2";
    appVersion = @"1.0.0";
    devMode = YES;

    blueKaiSdk = [[BlueKai alloc] initWithSiteId:siteId withAppVersion:appVersion withView:viewController withDevMode:devMode];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    NSLog(@"==>> %s", __PRETTY_FUNCTION__);
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testDesignatedInitMethod
{
    XCTAssertNotNil(blueKaiSdk, @"Object is not nil");
    XCTAssertEqual([blueKaiSdk siteId], siteId, @"siteId is not set");
    XCTAssertEqual([blueKaiSdk appVersion], appVersion, @"appVersion is not set");
    XCTAssertTrue([blueKaiSdk devMode], @"devMode should be TRUE");
    XCTAssertNotNil([blueKaiSdk viewController], @"viewController should not be nil");
}

- (void)testCanSetAppVersion
{
    NSString *newAppVersion = @"2.0.0";
    [blueKaiSdk setAppVersion:newAppVersion];
    XCTAssertEqual([blueKaiSdk appVersion], newAppVersion, @"new appVersion was not set");
}

- (void)testCanSetDevMode
{
    [blueKaiSdk setDevMode:YES];
    XCTAssertTrue([blueKaiSdk devMode], @"new devMode was not set");
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
    XCTAssertEqual([blueKaiSdk siteId], newSiteId, @"new siteId was not set");
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

@end
