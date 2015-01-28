//
//  BlueKai_Protected.h
//  Bluekai_SDK
//
//  Created by Shun Chu on 5/28/14.
//  Copyright (c) 2014 BlueKai. All rights reserved.
//

#import "BlueKai.h"

@interface BlueKai ()

// Protected methods
@property (strong, readwrite) NSMutableDictionary *keyValDict;
@property (strong, readwrite) NSMutableDictionary *nonLoadkeyValDict;
@property (strong, readwrite) NSMutableDictionary *remainkeyValDict;
@property (strong, readwrite) NSMutableString     *webUrl;
@property (strong, readwrite) NSUserDefaults      *userDefaults;
@property (strong, readwrite) NSMutableDictionary *dataParamsDict;

@end