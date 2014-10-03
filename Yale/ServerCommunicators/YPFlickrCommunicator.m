//
//  YPFlickrCommunicator.m
//  Yale
//
//  Created by Charly Walther on 10/3/14.
//  Copyright (c) 2014 Hengchu Zhang. All rights reserved.
//

#import "YPFlickrCommunicator.h"
#import "ObjectiveFlickr.h"
#import "Config.h"

@interface YPFlickrCommunicator () {
    OFFlickrAPIContext *_context;
}
@end

@implementation YPFlickrCommunicator

-(instancetype)init {
    _context = [[OFFlickrAPIContext alloc] initWithAPIKey:FLICKR_API_KEY sharedSecret:FLICKR_API_KEY];
    return self;
}

@end
