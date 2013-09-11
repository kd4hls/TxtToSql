//
//  SqlDb.h
//  TxtToSql
//
//  Created by Created by Jonathan ellis
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>


@interface SqlDb : NSObject
{
    sqlite3 *database;
}

- (sqlite3*)initWithPath:(NSString *)path;

- (NSArray *)performQuery:(NSString *)query;

@end

