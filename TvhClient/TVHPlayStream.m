//
//  TVHPlayStream.m
//  TvhClient
//
//  Created by Luis Fernandes on 26/10/13.
//  Copyright (c) 2013 Luis Fernandes.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "TVHPlayStream.h"
#import "TVHSettings.h"
#import "TVHServer.h"
#import "TVHSingletonServer.h"
#import "TVHPlayXbmc.h"

#define TVH_PROGRAMS @{@"VLC":@"vlc", @"Oplayer":@"oplayer", @"Buzz Player":@"buzzplayer", @"GoodPlayer":@"goodplayer", @"Ace Player":@"aceplayer" }
#define TVHS_TVHEADEND_STREAM_URL_INTERNAL @"?transcode=1&resolution=%@&vcodec=H264&acodec=AAC&scodec=PASS&mux=mpegts"
#define TVHS_TVHEADEND_STREAM_URL @"?transcode=1&resolution=%@&vcodec=H264&acodec=AAC&scodec=PASS"

@implementation TVHPlayStream

+ (id)sharedInstance {
    static TVHPlayStream *__sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[TVHPlayStream alloc] init];
    });
    
    return __sharedInstance;
}

#pragma MARK get programs

- (NSArray*)arrayOfAvailablePrograms {
    NSMutableArray *available = [[NSMutableArray alloc] init];
    for (NSString* key in TVH_PROGRAMS) {
        NSString *urlTarget = [TVH_PROGRAMS objectForKey:key];
        NSURL *url = [self urlForSchema:urlTarget withURL:nil];
        if( [[UIApplication sharedApplication] canOpenURL:url] ) {
            [available addObject:key];
        }
    }
    
    // custom
    NSString *customPrefix = [[TVHSettings sharedInstance] customPrefix];
    if( [customPrefix length] > 0 ) {
        NSURL *url = [self urlForSchema:customPrefix withURL:nil];
        if( [[UIApplication sharedApplication] canOpenURL:url] ) {
            [available addObject:NSLocalizedString(@"Custom Player", nil)];
        }
    }
    
    // xbmc
    [available addObjectsFromArray:[[TVHPlayXbmc sharedInstance] availableXbmcServers]];
    
    return [available copy];
}

- (BOOL)isTranscodingCapable {
    TVHServer *tvhServer = [TVHSingletonServer sharedServerInstance];
    return [tvhServer isTranscodingCapable];
}

#pragma MARK play stream

- (BOOL)playStreamIn:(NSString*)program forObject:(id<TVHPlayStreamDelegate>)streamObject withTranscoding:(BOOL)transcoding {
    
    if ( [self playInternalStreamIn:program forObject:streamObject withTranscoding:transcoding] ) {
        return true;
    }
    
    return [[TVHPlayXbmc sharedInstance] playToXbmc:program forObject:streamObject withTranscoding:transcoding];
}

- (BOOL)playInternalStreamIn:(NSString*)program forObject:(id<TVHPlayStreamDelegate>)streamObject withTranscoding:(BOOL)transcoding {
    NSString *streamUrl = [TVHPlayStream streamUrlFromObject:streamObject withTranscoding:transcoding];
    
    NSURL *myURL = [self URLforProgramWithName:program forURL:streamUrl];
    if ( myURL ) {
        [TVHAnalytics sendEventWithCategory:@"playTo"
                                 withAction:@"Internal"
                                  withLabel:program
                                  withValue:[NSNumber numberWithInt:1]];
        [[UIApplication sharedApplication] openURL:myURL];
        return true;
    }
    return false;
}

+ (NSString*)streamUrlFromObject:(id<TVHPlayStreamDelegate>)streamObject withTranscoding:(BOOL)transcoding {
    if ( transcoding ) {
        return [TVHPlayStream stringTranscodeUrl:[streamObject streamURL]];
    } else {
        return [streamObject streamURL];
    }
}

+ (NSString*)stringTranscodeUrl:(NSString*)url {
    TVHSettings *settings = [TVHSettings sharedInstance];
    return [url stringByAppendingFormat:TVHS_TVHEADEND_STREAM_URL, [settings transcodeResolution]];
}

+ (NSString*)stringTranscodeUrlInternalFormat:(NSString*)url {
    TVHSettings *settings = [TVHSettings sharedInstance];
    return [url stringByAppendingFormat:TVHS_TVHEADEND_STREAM_URL_INTERNAL, [settings transcodeResolution]];
}

- (NSURL*)URLforProgramWithName:(NSString*)title forURL:(NSString*)streamUrl {
    NSString *prefix = [TVH_PROGRAMS objectForKey:title];
    if ( prefix ) {
        NSURL *myURL = [self urlForSchema:prefix withURL:streamUrl];
        return myURL;
    }
    
    if ( [title isEqualToString:NSLocalizedString(@"Custom Player", nil)] ) {
        NSString *customPrefix = [[TVHSettings sharedInstance] customPrefix];
        NSString *url = [NSString stringWithFormat:@"%@://%@", customPrefix, streamUrl ];
        NSURL *myURL = [NSURL URLWithString:url];
        return myURL;
    }
    
    return nil;
}

- (NSURL*)urlForSchema:(NSString*)schema withURL:(NSString*)url {
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@", schema, url]];
}

@end
