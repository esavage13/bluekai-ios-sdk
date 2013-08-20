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


#import "Database.h"
static sqlite3 *database=nil;
@implementation Database

+(void)openDataBase:(NSString *)dbPath
{
    if(sqlite3_open([dbPath UTF8String],&database)==SQLITE_OK)
    {
        NSLog(@"Database Path Identified");
        sqlite3_close(database);
    }
    else{
        sqlite3_close(database);
        NSLog(@"Database Open error Identified");
    }
}
+(void)copyDataBaseIfNeeded
{
    NSString *strSqliteFilePath = [[NSBundle mainBundle]pathForResource:@"user_Info" ofType:@"sqlite"];
	NSLog(@"source path is %@",strSqliteFilePath);
	NSArray *docPathArr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *destPath = [NSString stringWithFormat:@"%@/user_Info.sqlite",[docPathArr objectAtIndex:0]];
	NSLog(@"destination path is %@",destPath);
	NSFileManager *manager = [[NSFileManager alloc]init];
	if ([manager fileExistsAtPath:destPath]) {
		NSLog(@"file already exists");
	}
	else {
		NSError *err;
		// copying the file to documents directory of the application
		if ([manager copyItemAtPath:strSqliteFilePath toPath:destPath error:&err])
        {
			NSLog(@"file copied successfully");
		}
		else
        {
			NSLog(@"error occured while copying %@",[err description]);
		}
        
	}
    [manager release];
}
+(NSString *)getDBPath
{
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    return [documentsDir stringByAppendingPathComponent:@"user_Info.sqlite"];
}
-(int)checkForAttempts:(NSString *)key:(NSString *)value
{
    sqlite3_stmt *stStatement=nil;
    if(sqlite3_open([[Database getDBPath] UTF8String],&database)==SQLITE_OK)
    {
        @try {
            NSString *query = [NSString stringWithFormat:@"SELECT attempts FROM key_values where key='%@' and value='%@'",key,value];
            
            if(sqlite3_prepare_v2(database, [query UTF8String], -1, &stStatement, nil)==SQLITE_OK)
            {
                while (sqlite3_step(stStatement)==SQLITE_ROW)
                {
                    int try=sqlite3_column_int(stStatement, 0);
                    return try;
                }
            }
        }
        @catch (NSException *exception) {
            NSLog(@"Exception while creating add statement %@",exception);
        }
        @finally {
            sqlite3_finalize(stStatement);
            sqlite3_close(database);
        }
    }
    else
    {
        sqlite3_close(database);
    }
    
    
	return 0;
}
-(void)insertUserDetails:(NSString *)key:(NSString *)value:(int)flag:(int)attempts
{
    sqlite3_stmt *addStmt=nil;
    if(sqlite3_open([[Database getDBPath] UTF8String],&database)==SQLITE_OK)
    {
        @try {
            if(addStmt==nil)
            {
                const char *sql="INSERT INTO key_values(key,value,flag,attempts) VALUES(?,?,?,?)";
                if(sqlite3_prepare_v2(database, sql, -1, &addStmt, NULL) != SQLITE_OK)
                    NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(database));
            }
            
            sqlite3_bind_text(addStmt, 1, [key UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(addStmt, 2, [value UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_int(addStmt, 3, flag);
            sqlite3_bind_int(addStmt, 4, attempts);
            if(sqlite3_step(addStmt) == SQLITE_DONE)
            {
                sqlite3_finalize(addStmt);
            }
            
        }
        @catch (NSException *exception) {
            NSLog(@"Exception while creating add statement %@",exception);
        }
        @finally {
          //  NSLog(@"Data Inserted");
            // sqlite3_finalize(addStmt);
            sqlite3_close(database);
        }
    }
    else
    {
        sqlite3_close(database);
    }
    
}

-(void)updateUserDetails:(NSString *)key:(NSString *)value:(int)attempts
{
    sqlite3_stmt *odrupdateStmt = nil;
    if(sqlite3_open([[Database getDBPath] UTF8String],&database)==SQLITE_OK)
    {
        @try {
            if(odrupdateStmt == nil) {
                const char *sql = "update key_values Set attempts = ? Where Key=? and value=?";
                if(sqlite3_prepare_v2(database, sql, -1, &odrupdateStmt, NULL) != SQLITE_OK)
                    NSAssert1(0, @"Error while creating update statement. '%s'", sqlite3_errmsg(database));
            }
            sqlite3_bind_int(odrupdateStmt, 1, attempts);
            sqlite3_bind_text(odrupdateStmt, 2, [key UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(odrupdateStmt, 3, [value UTF8String], -1, SQLITE_TRANSIENT);
            if(sqlite3_step(odrupdateStmt) == SQLITE_DONE)
            {
                sqlite3_finalize(odrupdateStmt);
            }
            // NSAssert1(0, @"Error while updating. '%s'", sqlite3_errmsg(database));
            
            
        }
        @catch (NSException *ex) {
            NSLog(@"Exception is %@",ex);
        }
        @finally {
            // sqlite3_finalize(odrupdateStmt);
            sqlite3_close(database);
        }
    }
    else
    {
        sqlite3_close(database);
    }
    
    
}
-(NSDictionary *)getKeyValues
{
    sqlite3_stmt *stStatement;
    if(sqlite3_open([[Database getDBPath] UTF8String],&database)==SQLITE_OK)
    {
        @try {
            NSString *query=[NSString stringWithFormat:@"SELECT key,value FROM key_values WHERE flag=1"];
            NSString *key=[NSString string];
            NSString *value=[NSString string];
            NSMutableDictionary *dictionary=[[[NSMutableDictionary alloc]init] autorelease];
            if(sqlite3_prepare_v2(database, [query UTF8String], -1, &stStatement, NULL)!=SQLITE_OK)
            {
                NSAssert1(0, @"Error while creating select statement. '%s'", sqlite3_errmsg(database));
            }
            while (sqlite3_step(stStatement)==SQLITE_ROW) {
                key=[NSString stringWithUTF8String:(char *)sqlite3_column_text(stStatement, 0)];
                value=[NSString stringWithUTF8String:(char *)sqlite3_column_text(stStatement, 1)];
                [dictionary setValue:value forKey:key];
            }
            if(stStatement != nil)
            {
                
            }return dictionary;
        }
        @catch (NSException *exception) {
            NSLog(@"Exception is %@",exception);
            return nil;
        }
        @finally {
            
            sqlite3_finalize(stStatement);
            sqlite3_close(database);
        }
    }
    else
    {
        sqlite3_close(database);
    }
    
    return nil;
}
-(void)deleteKeyValue:(NSString *)key:(NSString *)value
{
    if(sqlite3_open([[Database getDBPath] UTF8String],&database)==SQLITE_OK)
    {
        sqlite3_stmt *delete_stmt=nil;
        @try {
            const char *sql="DELETE FROM key_values where key=? and value=?";
            if(sqlite3_prepare_v2(database, sql, -1, &delete_stmt, NULL) !=SQLITE_OK)
                NSAssert1(0, @"Error while creating delete statement. '%s'", sqlite3_errmsg(database));
            
            sqlite3_bind_text(delete_stmt, 1, [key UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(delete_stmt, 2, [value UTF8String], -1, SQLITE_TRANSIENT);
            if(sqlite3_step(delete_stmt) == SQLITE_DONE)
            {
                sqlite3_finalize(delete_stmt);
            }
        }
        @catch (NSException *exception) {
            NSLog(@"Exception %@",exception);
        }
        @finally {
            sqlite3_close(database);
        }
    }
    else
    {
        sqlite3_close(database);
        NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(database));
    }
    
    
}

-(NSString *)getUserDataValue
{
    sqlite3_stmt *stStatement;
    if(sqlite3_open([[Database getDBPath] UTF8String],&database)==SQLITE_OK)
    {
        @try {
            NSString *query = [NSString stringWithFormat:@"SELECT user_data FROM user_data_settings"];
            NSString *response=[NSString string];
            response = @"YES";
            // NSMutableArray *datevalues=[[NSMutableArray alloc]init];
            if(sqlite3_prepare_v2(database, [query UTF8String], -1, &stStatement, NULL)!=SQLITE_OK)
            {
                NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(database));
            }
            
            while (sqlite3_step(stStatement)==SQLITE_ROW)
            {
                response=[NSString stringWithUTF8String:(char*)sqlite3_column_text(stStatement, 0)];
            }
            if (stStatement!= nil) {
            }
            return response;
        }
        @catch (NSException *ex) {
            NSLog(@"Exception is %@",ex);
            return nil;
        }
        @finally {
            sqlite3_finalize(stStatement);
            sqlite3_close(database);
        }
    }
    else
    {
        sqlite3_close(database);
        NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(database));
        
    }
    return nil;
}
-(void)insertUserDataValue:(NSString *)value
{
    sqlite3_stmt *addStmt = nil;
    if(sqlite3_open([[Database getDBPath] UTF8String],&database)==SQLITE_OK)
    {
        @try {
            if(addStmt == nil) {
                const char *sql = "INSERT INTO user_data_settings(user_data) VALUES(?)";
                if(sqlite3_prepare_v2(database, sql, -1, &addStmt, NULL) != SQLITE_OK)
                    NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(database));
            }
            
            sqlite3_bind_text(addStmt, 1, [value UTF8String], -1, SQLITE_TRANSIENT);
            if(sqlite3_step(addStmt) == SQLITE_DONE)
                sqlite3_finalize(addStmt);
            
            
        }
        @catch (NSException *ex) {
            NSLog(@"Exception is %@",ex);
        }
        @finally {
            sqlite3_close(database);
        }
    }
    else
    {
        sqlite3_close(database);
        NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(database));
    }
    
}
-(void)deleteUserData
{
    sqlite3_stmt *delete_stmt=nil;
    if(sqlite3_open([[Database getDBPath] UTF8String],&database)==SQLITE_OK)
    {
        @try {
            const char *sql="DELETE  FROM user_data_settings";
            if(sqlite3_prepare_v2(database, sql, -1, &delete_stmt, NULL) !=SQLITE_OK)
                NSAssert1(0, @"Error while creating delete statement. '%s'", sqlite3_errmsg(database));
            
            if(sqlite3_step(delete_stmt) == SQLITE_DONE)
            {
                sqlite3_finalize(delete_stmt);
            }
        }
        @catch (NSException *exception) {
            NSLog(@"Exception %@",exception);
        }
        @finally {
            sqlite3_close(database);
        }
    }
    else
    {
        sqlite3_close(database);
        NSAssert1(0, @"Error while creating delete statement. '%s'", sqlite3_errmsg(database));
    }
}

@end
