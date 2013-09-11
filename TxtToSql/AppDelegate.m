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
    NSString* Records;
    NSString* FileBuff;
    NSString* FileType;
    int count ;
    int  WsTableValue;
    int TblTime;
    NSUInteger DateStrLen;

    sqlite3 * newDBconnection = NULL;
    
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
            
            if (sqlite3_open([DbFile UTF8String], &newDBconnection) == SQLITE_OK)
            {
                if (Dbug)
                {
                    NSLog(@"findtxt: Database Successfully Opened-> %@)", DbFile);
                    
                    const char *sql = "SELECT * FROM indoorHeatIndex";
                    sqlite3_stmt *QryStatement;
                    
                    if (sqlite3_prepare(newDBconnection, sql, -1, &QryStatement, NULL) == SQLITE_OK)
                    {
                        if (sqlite3_step(QryStatement) == SQLITE_ROW)
                        {
                            TblTime = sqlite3_column_int(QryStatement, 0);
                            WsTableValue = sqlite3_column_int(QryStatement, 1);
                            NSLog(@"AppDelegate: sqlite3_prepare  %s)", sql);
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
                     
                            // now to loop through RowBuff line by line
                        count = 0;
                        for (Records in RowBuff)
                        {
                            count ++ ;
                            if (count > 3) // ignore headers
                            {
                                DateStrLen = [Records length];
                                if (DateStrLen > 80) // should be 84
                                {
                                    NSLog(@"findtxt: count %d", count );
                                    if (Dbug) NSLog(@"findtxt: Records %@", Records );
                                    [ConverterPtr LoadVars:newDBconnection :Records ];
                                }
                            }   // count
                        }   // 4 Records
                        sqlite3_close(newDBconnection);
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
}   // the end.....

@end


