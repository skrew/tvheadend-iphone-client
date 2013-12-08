//
//  TVHStringHelper.m
//  TvhClient
//
//  Created by Luis Fernandes on 06/03/13.
//  Copyright 2013 Luis Fernandes
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "NSString+FileSize.h"

@implementation NSString (NSStringWithFileSize)

+ (NSString*)stringFromFileSize:(unsigned long long)theSize {
    float floatSize = (float)theSize;
    
    if ( theSize == 0 ) {
        return @"0";
    }
    
    if ( theSize < 1023 ){
        return ([NSString stringWithFormat:@"%llul bytes",theSize]);
    }
    
    floatSize = floatSize / 1024;
    if ( floatSize < 1023 ){
        return ([NSString stringWithFormat:@"%1.1f KB",floatSize]);
    }
    
    floatSize = floatSize / 1024;
    if ( floatSize < 1023 ) {
        return ([NSString stringWithFormat:@"%1.1f MB",floatSize]);
    }
    
    floatSize = floatSize / 1024;
    if ( floatSize < 1023 ) {
        return ([NSString stringWithFormat:@"%1.1f GB",floatSize]);
    }
    
    floatSize = floatSize / 1024;
    return([NSString stringWithFormat:@"%1.1f TB",floatSize]);
}

+ (NSString*)stringFromFileSizeInBits:(unsigned long long)theSize {
    return [NSString stringFromFileSize: theSize*8];
}

+ (NSString*)stringOfWeekdaysLocalizedFromArray:(NSArray*)weekdays joinedByString:(NSString*)join {
    NSMutableArray *localizedDays = [[NSMutableArray alloc] init];
    
    NSMutableArray *localizedStringOfweekday = [[[[NSDateFormatter alloc] init] shortWeekdaySymbols] mutableCopy];
    // hack for making 1==monday 7==sunday
    [localizedStringOfweekday addObject:[localizedStringOfweekday objectAtIndex:0]];
    
    [weekdays enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *convertedDay = [localizedStringOfweekday objectAtIndex:[obj intValue]];
        [localizedDays addObject:convertedDay];
    }];
    return [localizedDays componentsJoinedByString:join];
}

@end
