//
//  ConvertBuff.m
//  TxtToSql
//
//  Created by Rodger Carroll on 9/3/13.
//  Copyright (c) 2013 Rodger Carroll. All rights reserved.
//

#import "ConvertBuff.h"

@implementation ConvertBuff

- (void)LoadVars: (sqlite3*) DataBasePtr : (NSArray*) RowBuff; // got the whole file
 {
    bool Dbug = 0;
    bool FirstRecord = 1;
    NSString* Records;
    NSUInteger DateStrLen;

    NSArray* inDate;
    NSArray* intime ;
    NSArray* hiTemp ;
    NSArray* lowTemp ;
    NSArray* Archcount ;
    int itmcount = 0;
    int reccount = 0;
    float MonthRain = 0;
    int TblDateInt;
    int LastDateInt;

    // segrugate the data
    NSArray* temp[21] ;
    NSArray* RowItems;
    NSString* var;
    NSDate*  dbTime;

      /// database stuff
    NSString* TblName;
    NSString* datestr;
    NSString* lastdatestr;
    NSString* yyyymm;
    NSString* TblValue;
    NSString* dayRain;
    float fdayRain;
     
     // if (Dbug) NSLog(@"findtxt: RowBuff %@", RowBuff ); only if your desperiate
         
         // now to loop through RowBuff line by line
    reccount = 0;
    for (Records in RowBuff)
    {
        reccount ++ ;
        if (reccount > 3) // ignore headers
        {
            DateStrLen = [Records length];
            if (DateStrLen > 80) // should be 84
            {
                NSLog(@"findtxt:itmcount %d", reccount );
                if (Dbug) NSLog(@"findtxt: Record %@", Records );
    
                RowItems = [Records componentsSeparatedByString:@"\t"];
                // if (Dbug) NSLog(@"RowItems %@", RowItems );

                //load array
               itmcount= 0; 
                for (var in RowItems)
                {
                    temp[itmcount] = [RowItems objectAtIndex: itmcount];
                    // if (Dbug) NSLog(@"LoadVars: %d  -> %@", itmcount, temp[itmcount]);
                   itmcount++;
                }

               itmcount= 0;  // recycle
                inDate = temp [itmcount];
               itmcount++;
                ////element 1 is blank due to double tabs
               itmcount++;
                intime = temp [itmcount ];
                datestr = [ SqlLoaderPtr unixtime: inDate: intime]; // date set
      
               itmcount++; // 3
                TblValue = (NSString*)temp [itmcount ];   
                TblName = @"indoorHeatIndex";
                [SqlLoaderPtr LoadDb: DataBasePtr: TblName: datestr: TblValue];
     
               itmcount++; //4
                TblValue = (NSString*)temp [itmcount ];     
                TblName = @"outdoorTemperature";
                [SqlLoaderPtr LoadDb: DataBasePtr: TblName: datestr: TblValue];
     
               itmcount++; //5
                TblValue = (NSString*)temp [itmcount ];
                TblName = @"windChill";
                [SqlLoaderPtr LoadDb: DataBasePtr: TblName: datestr: TblValue];
     
               itmcount++; //6
                hiTemp = temp [itmcount ];         //      
               itmcount++; //7
                lowTemp = temp [itmcount ];        //      
               itmcount++; //8
                TblValue = (NSString*)temp [itmcount ];
                TblName = @"outdoorHumidity";
                [SqlLoaderPtr LoadDb: DataBasePtr: TblName: datestr: TblValue];
     
               itmcount++; //9
                TblValue = (NSString*)temp [itmcount ];
                TblName = @"outdoorDewPoint";  
                [SqlLoaderPtr LoadDb: DataBasePtr: TblName: datestr: TblValue];
     
               itmcount++; //10
                TblValue = (NSString*)temp [itmcount ];
                TblName = @"windSpeed";
                [SqlLoaderPtr LoadDb: DataBasePtr: TblName: datestr: TblValue];
     
               itmcount++; //11
                TblValue = (NSString*)temp [itmcount ];
                TblName = @"windGust";
                [SqlLoaderPtr LoadDb: DataBasePtr: TblName: datestr: TblValue];
     
               itmcount++; //12
                TblValue = (NSString*)temp [itmcount ];
                TblName = @"windDirection";
                [SqlLoaderPtr LoadDb: DataBasePtr: TblName: datestr: TblValue];
                
                // rain for the month
                dbTime = [NSDate dateWithTimeIntervalSince1970:[datestr intValue]];
                yyyymm =  [SqlLoaderPtr yearmonth: dbTime] ;
                if (Dbug)NSLog(@"xferdata: got -> %@ %@)", dbTime, yyyymm);
                TblDateInt = [yyyymm intValue];

                if (FirstRecord)
                {
                    LastDateInt = TblDateInt;
                    FirstRecord = 0;
                }
                if (LastDateInt != TblDateInt)      // new month
                {
                    LastDateInt = TblDateInt;
                    TblValue = [NSString stringWithFormat:@"%f",MonthRain];
                    TblName = @"monthRain";
                    if (Dbug) NSLog(@"findtxt: fixin to LoadDb %@ %@ %@", TblName, lastdatestr, TblValue );
                    [SqlLoaderPtr LoadDb: DataBasePtr: TblName: lastdatestr: TblValue];
                    MonthRain = 0;
                }
                lastdatestr = datestr;
                              
                itmcount++; //13    dayRain
                TblValue = (NSString*)temp [itmcount ];
                MonthRain = MonthRain += [TblValue floatValue];
                if (Dbug)
                {
                    dayRain = TblValue;
                    fdayRain = [dayRain floatValue];
                    if (fdayRain > 0)
                        NSLog(@"findtxt: found rain %f", fdayRain );
                }
                TblName = @"dayRain";
                [SqlLoaderPtr LoadDb: DataBasePtr: TblName: datestr: TblValue];
     
               itmcount++; //14
                TblValue = (NSString*)temp [itmcount ];
                TblName = @"barometricPressure";
                [SqlLoaderPtr LoadDb: DataBasePtr: TblName: datestr: TblValue];
     
               itmcount++; //15
                TblValue = (NSString*)temp [itmcount ];
                TblName = @"indoorTemperature";
                [SqlLoaderPtr LoadDb: DataBasePtr: TblName: datestr: TblValue];
     
               itmcount++; //16
                TblValue = (NSString*)temp [itmcount ];
                TblName = @"indoorHumidity";
                [SqlLoaderPtr LoadDb: DataBasePtr: TblName: datestr: TblValue];
     
               itmcount++; //17
                Archcount = temp [itmcount ];      //
                
                dbTime = [NSDate dateWithTimeIntervalSince1970:[datestr intValue]];
                yyyymm =  [SqlLoaderPtr yearmonth: dbTime] ;
                if (Dbug)NSLog(@"xferdata: got -> %@ %@)", dbTime, yyyymm);
                TblDateInt = [yyyymm intValue];
                
            }       //  // DateStrLen > 80
        }       // reccount > 3
    }       // Records in RowBuff
            // now get the last MonthRain
     TblValue = [NSString stringWithFormat:@"%f",MonthRain];
     if (Dbug) NSLog(@"findtxt: fixin to LoadDb %@ %@ %@", TblName, datestr, TblValue );
     [SqlLoaderPtr LoadDb: DataBasePtr: TblName: lastdatestr: TblValue];
     
}   //  LoadVars 

- (void) LoadMonthRain:(sqlite3*) DataBasePtr : (NSArray*) RowBuff;
{
    bool Dbug = 1;
    bool FirstRecord = 1;
    NSString* Records;
    NSUInteger DateStrLen;
    
    NSArray* inDate;
    NSArray* intime ;
    int itmcount = 0;
    int reccount = 0;
    float MonthRain = 0;
    int TblDateInt;
    int LastDateInt;
    
    // segrugate the data
    NSArray* temp[21] ;
    NSArray* RowItems;
    NSString* var;
    NSDate*  dbTime;
    
    /// database stuff
    NSString* TblName = @"monthRain";
    NSString* datestr;
    NSString* lastdatestr;
    NSString* yyyymm;
    NSString* TblValue;
    NSString* dayRain;
    float fdayRain;
    
    // if (Dbug) NSLog(@"LoadMonthRain: RowBuff %@", RowBuff ); only if your desperate
    
    // now to loop through RowBuff line by line
    reccount = 0;
    for (Records in RowBuff)
    {
        reccount ++ ;
        if (reccount > 3) // ignore headers
        {
            DateStrLen = [Records length];
            if (DateStrLen > 80) // should be 84
            {
                NSLog(@"LoadMonthRain: itmcount %d", reccount );
                // if (Dbug) NSLog(@"LoadMonthRain: Record %@", Records );
                
                RowItems = [Records componentsSeparatedByString:@"\t"];
                // if (Dbug) NSLog(@"LoadMonthRain: RowItems %@", RowItems );
                
                //load array
                itmcount= 0;
                for (var in RowItems)
                {
                    temp[itmcount] = [RowItems objectAtIndex: itmcount];
                    // if (Dbug) NSLog(@"LoadMonthRain: %d  -> %@", itmcount, temp[itmcount]);
                    itmcount++;
                }
                
                inDate = temp [0];
                intime = temp [2 ];
                datestr = [ SqlLoaderPtr unixtime: inDate: intime]; // date set
                
                              // rain for the month
                dbTime = [NSDate dateWithTimeIntervalSince1970:[datestr intValue]];
                yyyymm =  [SqlLoaderPtr yearmonth: dbTime] ;
                // if (Dbug)NSLog(@"LoadMonthRain: got -> %@ %@)", dbTime, yyyymm);
                TblDateInt = [yyyymm intValue];
                
                if (FirstRecord)
                {
                    LastDateInt = TblDateInt;
                    FirstRecord = 0;
                }
                if (LastDateInt != TblDateInt)      // new month
                {
                    LastDateInt = TblDateInt;
                    TblValue = [NSString stringWithFormat:@"%f",MonthRain];
                    if (Dbug) NSLog(@"LoadMonthRain: fixin to LoadDb %@ %@ %@", TblName, lastdatestr, TblValue );
                    [SqlLoaderPtr LoadDb: DataBasePtr: TblName: lastdatestr: TblValue];
                    MonthRain = 0;
                }
                lastdatestr = datestr;
                
                TblValue = (NSString*)temp [13 ];
                MonthRain = MonthRain += [TblValue floatValue];
                if (Dbug)
                {
                    dayRain = TblValue;
                    fdayRain = [dayRain floatValue];
                    if (fdayRain > 0)
                        NSLog(@"LoadMonthRain: found rain %f", fdayRain );
                }
                            
                dbTime = [NSDate dateWithTimeIntervalSince1970:[datestr intValue]];
                yyyymm =  [SqlLoaderPtr yearmonth: dbTime] ;
                // if (Dbug)NSLog(@"LoadMonthRain: got -> %@ %@)", dbTime, yyyymm);
                TblDateInt = [yyyymm intValue];
                
            }       //  // DateStrLen > 80
        }   // reccount > 3
    }   // Records in RowBuff
        // now get the last month 
    TblValue = [NSString stringWithFormat:@"%f",MonthRain];
    if (Dbug) NSLog(@"LoadMonthRain: fixin to LoadDb %@ %@ %@", TblName, datestr, TblValue );
    [SqlLoaderPtr LoadDb: DataBasePtr: TblName: lastdatestr: TblValue];

}   //  LoadMonthRain


@end
