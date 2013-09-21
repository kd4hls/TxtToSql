//
//  AppDelegate.m
//  TxtToSql
//
//  Created by Rodger Carroll on 9/2/13.
//

#import "AppDelegate.h"

NSString* TxtFile;
NSString* DbFile;
NSString* type;
NSString* name;
NSString* tbl_name;

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    ConverterPtr = [ConvertBuff new];
    FileFinderPtr = [FileFinder new];
    SqlLoaderPtr = [SqlLoader new];
}

- (IBAction)findtxt:(id)sender
{
    _Bool Dbug = 0;
    
    NSArray* RowBuff;
    NSString* FileBuff;
    NSString* FileType;
    int  WsTableValue;
    int TblTime;
    sqlite3 * DbPtr = NULL;
    sqlite3_stmt *SqlReturned;
    const char * SqlCommand;
    
    FileType = @"txt";
 
    TxtFile = [FileFinderPtr GetFile:FileType];
    if ( TxtFile )
    {
        if (Dbug) NSLog(@"findtxt: TxtFile %@", TxtFile );
        
        FileType = NULL;
        FileType = @"db";
        DbFile = [FileFinderPtr GetFile:FileType];
        if ( DbFile )
        {
            if (Dbug) NSLog(@"findtxt: DbFile %@", DbFile );
            
            if (sqlite3_open_v2([DbFile UTF8String], &DbPtr, SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK)
            {
                if (Dbug)
                {
                    NSLog(@"findtxt: Database Successfully Opened-> %@)", DbFile);
                    
                    SqlCommand = "SELECT * FROM indoorHeatIndex";
                    
                    if (sqlite3_prepare(DbPtr, SqlCommand, -1, &SqlReturned, NULL) == SQLITE_OK)
                    {
                        if (sqlite3_step(SqlReturned) == SQLITE_ROW)
                        {
                            TblTime = sqlite3_column_int(SqlReturned, 0);
                            WsTableValue = sqlite3_column_int(SqlReturned, 1);
                            NSLog(@"AppDelegate: sqlite3_prepare  %s)", SqlCommand);
                            NSLog(@"AppDelegate: got -> %d %d)", TblTime, WsTableValue);
                        }
                        
                    }
                }
                
                
                    // Open  the document , FileBuff got the whole file as a string
                FileBuff = [NSString  stringWithContentsOfFile:TxtFile encoding:NSUTF8StringEncoding error:nil];
             
                if (FileBuff )
                {
                    if (Dbug) NSLog(@"findtxt: FileBuff %@",  FileBuff );
                 
                        // RowBuff got the whole file by rows
                    RowBuff = [FileBuff componentsSeparatedByString:@"\n"];
                    if (RowBuff )
                    {
                        if (Dbug) NSLog(@"findtxt: RowBuff %@", RowBuff );
                     
                        [ConverterPtr LoadVars:DbPtr :RowBuff ];
                        //[ConverterPtr LoadMonthRain:DbPtr :RowBuff ];

                    }   //  if RowBuff
                }   //  if FileBuff
                else
                    NSLog(@"findtxt: FileBuff Error %@", FileBuff );
        
            }   //  if Sql3Ptr
            else
                NSLog(@"findtxt: DataBase Not opened %@", DbFile );
                
        }   // if DbFile
        else
            NSLog(@"findtxt: DbFile Not found %@", DbFile );
    }   // TxtFile
    else
        NSLog(@"findtxt: TxtFile  Not found %@", TxtFile );
    
    NSLog(@"findtxt: fixin to close " );
    sqlite3_close(DbPtr);
}   // the end.....

@end


