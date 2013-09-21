//
//  ConvertBuff.h
//  TxtToSql
//
//  Created by Rodger Carroll on 9/3/13.
//

#import <Foundation/Foundation.h>
#import "SqlLoader.h"

SqlLoader * SqlLoaderPtr;

@interface ConvertBuff : NSObject

- (void) LoadVars:(sqlite3*) DataBasePtr  : (NSArray*) RowBuff;

- (void) LoadMonthRain:(sqlite3*) DataBasePtr  : (NSArray*) RowBuff;

@end

