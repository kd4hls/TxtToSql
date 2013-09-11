//
//  FileFinder.m
//  WlTxtToWsdb
//
//  Created by Rodger Carroll on 9/6/13.
//

#import "FileFinder.h"


@implementation FileFinder

- (NSString*)GetFile:(NSString*) FileType;
{
    bool Dbug = 0;
    
    NSOpenPanel* panel;
    NSArray* filesfound;
    NSString* FileName;
    NSError *error;
    NSURL*  InFid;

    
    if (Dbug) NSLog(@"GetFile:  %@", FileType);
    panel = [NSOpenPanel openPanel];
    
    filesfound = [ [NSArray alloc] initWithObjects:FileType, nil];
    panel = [NSOpenPanel openPanel];
    [panel setFloatingPanel:YES];
    [panel setCanChooseDirectories:NO];
    [panel setCanChooseFiles:YES];
    [panel setAllowsMultipleSelection:NO];
    [panel setAllowedFileTypes:filesfound];
    
    NSInteger result = [panel runModal];
    {
         if ((result == NSOKButton) || (result != NSCancelButton))
         {
             InFid = [[panel URLs] objectAtIndex:0];
             FileName = [InFid path];
             if (Dbug) NSLog(@"GetFile:found file  %@", FileName);
         }
         else 
             NSLog(@"GetFile:file Not found at %ld\n%@", (long)result, [error localizedFailureReason]);
   
     };     // end of panel
    return( FileName);
}
@end
