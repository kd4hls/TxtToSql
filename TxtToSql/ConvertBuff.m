//
//  ConvertBuff.m
//  TxtToSql
//
//  Created by Rodger Carroll on 9/3/13.
//  Copyright (c) 2013 Rodger Carroll. All rights reserved.
//

#import "ConvertBuff.h"

@implementation ConvertBuff

- (void)LoadVars: (sqlite3*) DataBasePtr : (NSString*)  currentRow;
 {
    _Bool Dbug = 0;
    NSArray* inDate;
    NSArray* intime ;
    NSArray* hiTemp ;
    NSArray* lowTemp ;
    NSArray* Archcount ;
    int count = 0;
    // segrugate the data
    NSArray* temp[20] ;
    NSArray* RowItems;
    NSString* var;
      /// database stuff
    NSString* TblName;
    NSString* datestr;
    NSString* TblValue;
         
    if (Dbug) NSLog(@"LoadVars: currentRow %@", currentRow );
    RowItems = [currentRow componentsSeparatedByString:@"\t"];
    if (Dbug) NSLog(@"RowItems %@", RowItems );

    //load array
    for (var in RowItems)
    {
        temp[count] = [RowItems objectAtIndex:count];
        if (Dbug) NSLog(@"LoadVars: %d  -> %@", count, temp[count]);
        count ++;
    }

    count = 0;
    inDate = temp [count];
    count ++;
    ////element 1 is blank due to double tabs
    count ++;
    intime = temp [count ];
    datestr = [ SqlLoaderPtr unixtime: inDate: intime];
      
    count ++; // 3
    TblValue = (NSString*)temp [count ];   
    TblName = @"indoorHeatIndex";
    [SqlLoaderPtr LoadDb: DataBasePtr: TblName: datestr: TblValue];
     
    count ++; //4
    TblValue = (NSString*)temp [count ];     
    TblName = @"outdoorTemperature";
    [SqlLoaderPtr LoadDb: DataBasePtr: TblName: datestr: TblValue];
     
    count ++; //5
    TblValue = (NSString*)temp [count ];
    TblName = @"windChill";
    [SqlLoaderPtr LoadDb: DataBasePtr: TblName: datestr: TblValue];
     
    count ++; //6
    hiTemp = temp [count ];         //      
    count ++; //7
    lowTemp = temp [count ];        //      
    count ++; //8
    TblValue = (NSString*)temp [count ];
    TblName = @"outdoorHumidity";
    [SqlLoaderPtr LoadDb: DataBasePtr: TblName: datestr: TblValue];
     
    count ++; //9
    TblValue = (NSString*)temp [count ];
    TblName = @"outdoorDewPoint";  
    [SqlLoaderPtr LoadDb: DataBasePtr: TblName: datestr: TblValue];
     
    count ++; //10
    TblValue = (NSString*)temp [count ];
    TblName = @"windSpeed";
    [SqlLoaderPtr LoadDb: DataBasePtr: TblName: datestr: TblValue];
     
    count ++; //11
    TblValue = (NSString*)temp [count ];
    TblName = @"windGust";
    [SqlLoaderPtr LoadDb: DataBasePtr: TblName: datestr: TblValue];
     
    count ++; //12
    TblValue = (NSString*)temp [count ];
    TblName = @"windDirection";
    [SqlLoaderPtr LoadDb: DataBasePtr: TblName: datestr: TblValue];
     
    count ++; //13
    TblValue = (NSString*)temp [count ];
    TblName = @"dayRain";
    [SqlLoaderPtr LoadDb: DataBasePtr: TblName: datestr: TblValue];
     
    count ++; //14
    TblValue = (NSString*)temp [count ];
    TblName = @"barometricPressure";
    [SqlLoaderPtr LoadDb: DataBasePtr: TblName: datestr: TblValue];
     
    count ++; //15
    TblValue = (NSString*)temp [count ];
    TblName = @"indoorTemperature";
    [SqlLoaderPtr LoadDb: DataBasePtr: TblName: datestr: TblValue];
     
    count ++; //16
    TblValue = (NSString*)temp [count ];
    TblName = @"indoorHumidity";
    [SqlLoaderPtr LoadDb: DataBasePtr: TblName: datestr: TblValue];
     
    count ++; //17
    Archcount = temp [count ];      //      
     
         // end of mac record
}

@end
