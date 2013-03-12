//
//  TVHDvrActions.m
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/28/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHDvrActions.h"
#import "TVHJsonClient.h"
#import "TVHDvrStore.h"

@implementation TVHDvrActions

+ (void)doDvrAction:(NSString*)action withId:(NSInteger)idint withIdName:(NSString*)idName withConfigName:(NSString*)configName {
    TVHJsonClient *httpClient = [TVHJsonClient sharedInstance];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSString stringWithFormat:@"%d", idint ],
                                   idName,
                                   action,
                                   @"op",
                                   configName,
                                   @"configName",nil];
    
    [httpClient postPath:@"/dvr" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSError* error;
        NSDictionary *json = [TVHJsonClient convertFromJsonToObject:responseObject error:error];
        if( error ) {
#ifdef TESTING
            NSLog(@"[DVR ACTIONS ERROR processing JSON]: %@", error.localizedDescription);
#endif
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"didErrorDvrAction"
             object:error];
        }
        NSInteger success = [[json objectForKey:@"success"] intValue];
        if ( success ) {
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"didSuccessDvrAction"
             object:action];
        } else {
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"didReturnErrorDvrAction"
             object:action];
        }
        
        // reload dvr
        TVHDvrStore *store = [TVHDvrStore sharedInstance];
        [store fetchDvr];
        
        //NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        //NSLog(@"Request Successful, response '%@'", responseStr);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
#ifdef TESTING
        NSLog(@"[DVR ACTIONS ERROR]: %@", error.localizedDescription);
#endif
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"didErrorDvrAction"
         object:error];
    }];

}

+ (void)addRecording:(NSInteger)eventId withConfigName:(NSString*)configName {
    // there is also a recordSeries action... 
    [TVHDvrActions doDvrAction:@"recordEvent" withId:eventId withIdName:@"eventId" withConfigName:configName];
}

+ (void)cancelRecording:(NSInteger)entryId{
    [TVHDvrActions doDvrAction:@"cancelEntry" withId:entryId withIdName:@"entryId" withConfigName:nil];
}

+ (void)deleteRecording:(NSInteger)entryId{
    [TVHDvrActions doDvrAction:@"deleteEntry" withId:entryId withIdName:@"entryId" withConfigName:nil];
}

@end
