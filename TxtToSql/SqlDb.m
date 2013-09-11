//
//  SqlDb.m
//  TxtToSql
//
//  Created by Jonathan ellis 
//  

#import "SqlDb.h"

@implementation SqlDb

- (sqlite3*)initWithPath:(NSString *)path;
{
    bool Dbug = 1;
    sqlite3 *dbConnection = NULL;
    
    if (Dbug) NSLog(@"SqlDb:initWithPath path-> %@", path);

    // if (self = [super init])
    {
                
        if (sqlite3_open([path UTF8String], &dbConnection) != SQLITE_OK)
        {
            NSLog(@"SqlDb:initWithPath Unable to open database!");
            return nil; // if it fails, return nil obj
        }
        database = dbConnection;
        if (Dbug) NSLog(@"SqlDb:initWithPath %@", database);
    }
    //return self;
    return dbConnection;
}

- (NSArray *)performQuery:(NSString *)query;
{
    bool Dbug = 1;
   
    sqlite3_stmt *statement = nil;
    const char *sql = [query UTF8String];
    
    if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK)
    {
        NSLog(@"[SQLITE] Error when preparing query!");
    }
    else
    {
        NSMutableArray *result = [NSMutableArray array];
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            NSMutableArray *row = [NSMutableArray array];
            for (int i=0; i<sqlite3_column_count(statement); i++)
            {
                int colType = sqlite3_column_type(statement, i);
                id value;
                if (colType == SQLITE_TEXT)
                {
                    const unsigned char *col = sqlite3_column_text(statement, i);
                    value = [NSString stringWithFormat:@"%s", col];
                } else if (colType == SQLITE_INTEGER)
                {
                    int col = sqlite3_column_int(statement, i);
                    value = [NSNumber numberWithInt:col];
                } else if (colType == SQLITE_FLOAT)
                {
                    double col = sqlite3_column_double(statement, i);
                    value = [NSNumber numberWithDouble:col];
                } else if (colType == SQLITE_NULL)
                {
                    value = [NSNull null];
                }
                else
                {
                    NSLog(@"[SQLITE] UNKNOWN DATATYPE");
                }
                
                [row addObject:value];
            }
            [result addObject:row];
        }
        if (Dbug) NSLog(@"SqlDb: performQuery %@", result);
        return result;
    }
    return nil;
}


@end
