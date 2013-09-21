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
    sqlite3_stmt *SqlReturned;
    const char * SqlCommand;
    
    if (Dbug) NSLog(@"LoadDb: -> %@ %@ %@)", TblName, TblTime,TblValue);
    
    NSString* insertQuery;
  
    insertQuery = @"INSERT INTO ";
    insertQuery = [insertQuery stringByAppendingString:TblName];
    insertQuery = [insertQuery stringByAppendingString:@" (time, value) VALUES ( '"];
    insertQuery = [insertQuery stringByAppendingString:TblTime];
    insertQuery = [insertQuery stringByAppendingString:@"', '"];
    insertQuery = [insertQuery stringByAppendingString:TblValue];
    insertQuery = [insertQuery stringByAppendingString:@"');"];
    
    if (Dbug) NSLog(@"LoadDb: insertQuery-> %@)", insertQuery);
    
    SqlCommand= [insertQuery UTF8String ];
    
    if (sqlite3_prepare_v2(DataBasePtr, SqlCommand, -1, &SqlReturned, NULL) == SQLITE_OK)
    {
        if (Dbug) NSLog(@"LoadDb: sqlite3_prepare successful )" );
        if (sqlite3_step(SqlReturned) == SQLITE_DONE)
        {
            if (Dbug) NSLog(@"LoadDb: insertStmt successful )" );
        }
        else
        {
            NSLog(@"LoadDb: insertQuery-> %@)", insertQuery);
            NSLog(@"LoadDb : insert failour  %s", sqlite3_errmsg(DataBasePtr));
        }
    }
    else
    {
        NSLog(@"LoadDb: insertQuery-> %@)", insertQuery);
        NSLog(@"LoadDb : sqlite3_prepare failour  %s", sqlite3_errmsg(DataBasePtr));
    }
    sqlite3_finalize(SqlReturned);
}       //  LoadDb


-(sqlite3 *) findraindb: (NSString*) FileName;
{

    bool Dbug = 0;
    NSArray * PathArray;
    NSString* RainDb;
    float TblTime;
    double TblValue;
    int count = 0;
    NSString* var;
    NSMutableArray* temp[20] ;
    sqlite3 * RainDbPtr = NULL;
    sqlite3_stmt *SqlReturned;   
    const char * SqlCommand;
    char *errMsg;
    NSFileManager *filemgr;
    
    if (Dbug)NSLog(@"findraindb: FileName->%@", FileName );
    // parse ArchiveDb for the path, append raindb, if NOT exist create it.
    
    PathArray = [FileName componentsSeparatedByString:@"/"];
    //if (Dbug) NSLog(@"findraindb: PathArray->%@", PathArray );
    // file name is after last slash
    for (var in PathArray)
    {
        temp[count] = [PathArray objectAtIndex:count];
        //if (Dbug) NSLog(@"findraindb: PathArray %d  -> %@", count, temp[count]);
        count ++;
    }
    count = count - 2 ; // just the path
    RainDb = @"/";
    for(int i=1; i<=count; i++) // index 0 is null 1st /
    {
        RainDb = [RainDb stringByAppendingString:(NSString *) temp[i] ];
        RainDb = [RainDb stringByAppendingString:@"/"];
        //if (Dbug) NSLog(@"findraindb: path->%@", RainDb);
    }
    RainDb = [RainDb stringByAppendingString:@"rain.db"];
    if (Dbug) NSLog(@"findraindb: path->%@", RainDb);
    // gotit 
  
    filemgr = [NSFileManager defaultManager];
    
    if ([filemgr fileExistsAtPath: RainDb ] == NO)
    {
        if (sqlite3_open_v2([RainDb UTF8String], &RainDbPtr, SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK)
        {
            if (Dbug) NSLog(@"findraindb: Created -> %@" ,RainDb);
            
            SqlCommand = "CREATE TABLE IF NOT EXISTS monthlyRain (time INTEGER PRIMARY KEY , value INTEGER )";
            
            if (sqlite3_exec(RainDbPtr, SqlCommand, NULL, NULL, &errMsg) == SQLITE_OK)
            {
                if (Dbug) NSLog(@"findraindb: OK ->%s", SqlCommand );
            }
            else
            {
                NSLog(@"findraindb: sqlite3_exec Failed->%s %s", SqlCommand , errMsg );
            }
        }
        else
        {
            NSLog(@"findraindb: sqlite3_open_v2 SQLITE_OPEN_CREATE Failed ->" );
        }
    }
    else // rain.db already exists
    {
        if (sqlite3_open_v2([RainDb UTF8String], &RainDbPtr, SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK)
        {
            if (Dbug)
            {
                NSLog(@"findraindb: Database Successfully Opened -> %@)", RainDb);
                
                SqlCommand= "SELECT * FROM monthlyRain";
                
                if (sqlite3_prepare_v2(RainDbPtr, SqlCommand, -1, &SqlReturned, NULL) == SQLITE_OK)
                {
                    if (sqlite3_step(SqlReturned) == SQLITE_ROW)
                    {
                        TblTime = sqlite3_column_int(SqlReturned, 0);
                        TblValue = sqlite3_column_double (SqlReturned, 1);
                        NSLog(@"findraindb: sqlite3_prepare  %s)", SqlCommand);
                        NSLog(@"findraindb: got -> %f %f)", TblTime, TblValue);
                    }
                }
                else
                {
                    NSLog(@"findraindb: sqlite3_prepare_v2 Failed->%s %s", SqlCommand , sqlite3_errmsg(RainDbPtr));
                }
            }

        }
        else        //  sqlite3_open_v2 ok
        {
            NSLog(@"findraindb: sqlite3_open_v2 Failed to open database-> /n %s" , sqlite3_errmsg(RainDbPtr));
        }
    }       //  fileExistsAtPath
    
    return (RainDbPtr);
    
}   //  findraindb

- (void) xferdata: (sqlite3 *) ArchiveDbPtr : (sqlite3 *) RainDbPtr;
{
    bool Dbug = 1;
    bool FirstRecord = 1;
    int ThisMonth = 0;
    int TblDateInt;
    float TblTime;
    double TblValue;
    double SvValue = 0;
    NSDate * SvTime = 0;
    NSDate*  dbTime;
    NSString* DateStr;
    //NSString* UnixDateStr;
    NSString* ValueStr;
    NSString* TblName;
    sqlite3_stmt *SqlReturned;
    const char * SqlCommand;
    
    if (Dbug) NSLog(@"xferdata: started" );
     
    SqlCommand = "SELECT * FROM monthRain";
    
    if (sqlite3_prepare(ArchiveDbPtr, SqlCommand, -1, &SqlReturned, NULL) == SQLITE_OK) // 0
    {
        int stepResult = sqlite3_step(SqlReturned);
        if (Dbug)NSLog(@"xferdata: sqlite3_prepare  %s)", SqlCommand);
        if (Dbug)NSLog(@"xferdata: sqlite stepResult  %d ", stepResult );
        
        if (stepResult == SQLITE_ROW) // got data in monthRain
        {
            while (stepResult == SQLITE_ROW)    // process what you got
            {
                if (sqlite3_step(SqlReturned) == SQLITE_ROW) // another row ready
                {
                    TblTime = sqlite3_column_int(SqlReturned, 0);
                    TblValue = sqlite3_column_double (SqlReturned, 1);
                    dbTime = [NSDate dateWithTimeIntervalSince1970:TblTime];
                    if (Dbug)NSLog(@"xferdata: got -> %@ %f)", dbTime, TblValue);
                
                    if (SvValue > TblValue) // previus monthRain > current :: *should be new month
                    {
                        DateStr =  [SqlLoaderPtr yearmonth: SvTime] ;
                        ValueStr = [NSString stringWithFormat:@"%f ", SvValue];
                        [SqlLoaderPtr LoadDb:  RainDbPtr :  TblName :  DateStr : ValueStr];
                        if (Dbug)NSLog(@"xferdata: update -> %@ %@ %@)", TblName ,  DateStr , ValueStr);
                        SvValue = TblValue;
                        SvTime = dbTime;
                    }
                    else
                    {
                        SvValue = TblValue;
                        SvTime = dbTime;
                    }
                }   // if sqlite3_step 
                // skip partial months data
                stepResult = sqlite3_step(SqlReturned);
            }   // while stepResult == SQLITE_ROW
        }      //    if stepResult == SQLITE_DONE
        else    //  no monthly rain , gota compute it
        {
            if (Dbug)NSLog(@"xferdata: got no monthRain -  gota compute it & update both databases )");
            SqlCommand = "SELECT * FROM dayRain";
            
            if (sqlite3_prepare(ArchiveDbPtr, SqlCommand, -1, &SqlReturned, NULL) == SQLITE_OK)
            {
                int stepResult = sqlite3_step(SqlReturned);
                if (Dbug)NSLog(@"xferdata: sqlite3_prepare  %s)", SqlCommand);
                if (Dbug)NSLog(@"xferdata: sqlite stepResult %d", stepResult );
                
                if (stepResult != SQLITE_DONE) // got data in monthRain
                {
                    while (stepResult == SQLITE_ROW)    // process what you got
                    {
                        if (sqlite3_step(SqlReturned) == SQLITE_ROW)
                        {
                            TblTime = sqlite3_column_int(SqlReturned, 0);
                            TblValue = sqlite3_column_double (SqlReturned, 1);
                            dbTime = [NSDate dateWithTimeIntervalSince1970:TblTime];
                            DateStr =  [SqlLoaderPtr yearmonth: dbTime] ;
                            if (Dbug)NSLog(@"xferdata: got -> %@ %f)", dbTime, TblValue);
                            TblDateInt = [DateStr intValue];
                        
                            if (FirstRecord)
                            {
                                ThisMonth = TblDateInt; // skip it
                                FirstRecord = 0;
                            }

                            if ( TblDateInt != ThisMonth) // should be new month , write what you got
                            {
                                DateStr =  [SqlLoaderPtr yearmonth: SvTime] ;
                                SvValue += TblValue;
                                ValueStr = [NSString stringWithFormat:@"%f ", SvValue];
                            
                                //TblName = @"monthRain";
                                // UnixDateStr = [NSString stringWithFormat:@"%f ", TblTime];
                                //  [SqlLoaderPtr LoadDb:  ArchiveDbPtr :  TblName :  UnixDateStr : ValueStr];
                            
                                TblName = @"monthlyRain";
                                [SqlLoaderPtr LoadDb:  RainDbPtr :  TblName :  DateStr : ValueStr];

                                if (Dbug)NSLog(@"xferdata: update -> %@ %@ %@)", TblName ,  DateStr , ValueStr);
                                SvValue = 0;
                                SvTime = dbTime;
                                ThisMonth = TblDateInt;
                            }
                            else
                            {
                                SvValue += TblValue;
                                SvTime = dbTime;        //  last record time found
                            }
                        }   // if sqlite3_step
                        // skip partial months data
                    stepResult = sqlite3_step(SqlReturned);
                    }   // while stepResult == SQLITE_ROW
                }
            }
        }

    }    //   if sqlite3_prepare
       
    if (Dbug)NSLog(@"xferdata: done)"); 
    sqlite3_finalize(SqlReturned);
   
    
}   //  xferdata

- (NSString*) yearmonth: (NSDate *) inDate ;
{

    bool Dbug = 0;
    NSString * YYYYMM;
    NSString * datestr;
    NSString * year;
    NSString * month;
    
    
    if (Dbug) NSLog(@"yearmonth: inDate %@", inDate );
    
    datestr = [NSString stringWithFormat:@"%@ ", inDate];
    if (Dbug) NSLog(@"yearmonth: datestr %@", datestr );
    
    year = [datestr substringToIndex:4];
    month = [datestr substringWithRange:NSMakeRange(5,2)];
    if (Dbug) NSLog(@"yearmonth : year month:  %@%@", year ,month);
    
    YYYYMM = year;
    YYYYMM = [YYYYMM stringByAppendingString: month];
    if (Dbug) NSLog(@"yearmonth : YYYYMM:  %@", YYYYMM);
    
    return (YYYYMM);
}       //  yearmonth

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
}   //  unixtime


@end
