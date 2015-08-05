//
//  Trip.m
//  Sidekick
//
//  Created by Tony Francis on 7/17/15.
//  Copyright (c) 2015 thesquad. All rights reserved.
//

#import "Trip.h"
#import <Parse/PFObject+Subclass.h>

@implementation Trip

@dynamic date;
@dynamic distance;
@dynamic secondsSpentBiking;
@dynamic endLocation;
@dynamic startLocationString;
@dynamic endLocationString;
@dynamic mapImage;

@synthesize route = _route;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Trip";
}

@end
