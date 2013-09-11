//
//  SqlLoader.h
//  TxtToSql
//
//  Created by Rodger Carroll on 9/10/13.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface SqlLoader : NSObject

- (void) LoadDb: (sqlite3 *) DataBasePtr : (NSString*) TblName : (NSString*) TblTime : (NSString*) TblValue;

- (NSString*) unixtime: (NSArray*) inDate : (NSArray*) intime ;

@end
