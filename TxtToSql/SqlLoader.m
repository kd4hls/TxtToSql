//
//  SqlLoader.m
//  TxtToSql
//
//  Created by Rodger Carroll on 9/10/13.
//

#import "SqlLoader.h"

@implementation SqlLoader

- (void) LoadDb: (sqlite3 *) DataBasePtr : (NSString*) TblName : (NSString*) TblTime : (NSString*) TblValue;

{
    _Bool Dbug = 0;
    
    if (Dbug) NSLog(@"LoadDb: -> %@ %@ %@)", TblName, TblTime,TblValue);
    
    NSString* insertQuery;
    const char *sql ;
    sqlite3_stmt *insertStmt;   // returned from sqlite3_prepare
    
    insertQuery = @"INSERT INTO ";
    insertQuery = [insertQuery stringByAppendingString:TblName];
    insertQuery = [insertQuery stringByAppendingString:@" (time, value) VALUES ( '"];
    insertQuery = [insertQuery stringByAppendingString:TblTime];
    insertQuery = [insertQuery stringByAppendingString:@"', '"];
    insertQuery = [insertQuery stringByAppendingString:TblValue];
    insertQuery = [insertQuery stringByAppendingString:@"');"];
    
    if (Dbug) NSLog(@"LoadDb: sqlite3_prepare -> %@)", insertQuery);
    
    sql = [insertQuery UTF8String ];
    
    sqlite3_prepare(DataBasePtr, sql, -1, &insertStmt, NULL);
    
    if (sqlite3_step(insertStmt) == SQLITE_DONE)
    {
        if (Dbug) NSLog(@"LoadDb: sqlite3_prepare successful )" );
    }
    else
    {
        NSLog(@"insert not successfull  %@", insertQuery);
    }
    sqlite3_finalize(insertStmt);
    
}

- (NSString*) unixtime: (NSArray*) inDate : (NSArray*) intime;
{
    bool Dbug = 0;
    NSDate *date;
    //    NSTimeInterval unixepoch;

    NSString* DateStr;
    NSString* TimeStr;
    //    NSString* LeadingZero = @"0";
    NSUInteger DateStrLen;
    NSInteger seconds = 0;
    NSDateFormatter* dateFormat = [NSDateFormatter new];
    NSTimeZone *timeZone;
    int TblTime;
    NSString* datestr;
    if (Dbug)NSLog(@"unixtime: inDate intime %@ %@", inDate, intime );
    
    //     convert string to unixepoch
    DateStr = (NSString*) inDate;
    DateStrLen = [DateStr length];
    if (DateStrLen < 8)
        DateStr = [@"0" stringByAppendingString: DateStr];
    // MM-dd-yy
    DateStr = [DateStr stringByAppendingString:@" "];
    if (Dbug)NSLog(@"unixtime: DateStr %@", DateStr );
    TimeStr = [DateStr stringByAppendingString:(NSString*) intime];
    if (Dbug)NSLog(@"unixtime: TimeStr %@", TimeStr );
    
    dateFormat.dateFormat = @"MM-dd-yy  hh:mm a";
    dateFormat.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] ;
    timeZone = [NSTimeZone timeZoneForSecondsFromGMT:seconds];
    if (Dbug)NSLog(@"unixtime: timeZone %ld", (long)timeZone );
    [dateFormat setTimeZone:timeZone];
    
    date = [dateFormat dateFromString:TimeStr];
    if (Dbug)NSLog(@"unixtime: Date %@", date );
    
    TblTime = [date timeIntervalSince1970];
    // finally! the date expression we need
    if (Dbug)NSLog(@"unixtime: TblTime %d", TblTime );
    datestr = [NSString stringWithFormat:@"%d ", TblTime];
    
    return (datestr);
}


@end
