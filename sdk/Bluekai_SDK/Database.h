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
#import <sqlite3.h>
@interface Database : NSObject
{
    NSString *db_Path;
}
+(void)openDataBase:(NSString *)dbPath;
+(void)copyDataBaseIfNeeded;
+(NSString *)getDBPath;
-(int)checkForAttempts:(NSString *)key:(NSString *)value;
-(void)insertUserDetails:(NSString *)key:(NSString *)value:(int)flag:(int)attempts;
-(void)updateUserDetails:(NSString *)key:(NSString *)value:(int)attempts;
-(NSDictionary *)getKeyValues;
-(void)deleteKeyValue:(NSString *)key:(NSString *)value;
-(NSString *)getUserDataValue;
-(void)insertUserDataValue:(NSString *)value;
-(void)deleteUserData;
@end
