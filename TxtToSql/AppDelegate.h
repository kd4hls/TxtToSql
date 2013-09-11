//
//  AppDelegate.h
//  TxtToSql
//
//  Created by Rodger Carroll on 9/2/13.
//

#import <Cocoa/Cocoa.h>
#import "ConvertBuff.h"
#import "FileFinder.h"
#import <sqlite3.h>

//  local vars

FileFinder * FileFinderPtr;
ConvertBuff * ConverterPtr;


@interface AppDelegate : NSObject <NSApplicationDelegate>


@property (assign) IBOutlet NSWindow *window;

- (IBAction)findtxt:(id)sender;

@end




