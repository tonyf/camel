//
//  TripLogManager.m
//  Sidekick
//
//  Created by Tony Francis on 7/17/15.
//  Copyright (c) 2015 thesquad. All rights reserved.
//

#import "TripLogManager.h"
#import "Trip.h"
#import <Parse/Parse.h>

@interface TripLogManager ()
@property (nonatomic, strong) NSMutableArray *trips;
@end

@implementation TripLogManager

+ (TripLogManager *)sharedInstance {
    static TripLogManager *sharedTripLogManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedTripLogManager = [[self alloc] init];
    });
    return sharedTripLogManager;
}

- (instancetype)init {
    if (self = [super init]) {
        _trips = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSArray *)trips {
    return [_trips copy];
}

- (void)loadTrips:(completion) completion {
    PFUser *user = [PFUser currentUser];
    PFRelation *tripRelation = [user relationForKey:@"trips"];
    PFQuery *query = [tripRelation query];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"[Parse] Query Error: %@", error);
        } else {
            _trips = [objects mutableCopy];
            completion(YES);
        }
    }];
}

- (void)deleteTrip:(Trip *)trip {
    [_trips removeObject:trip];
    [trip deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!succeeded) {
            NSLog(@"[Parse] Delete Error: %@", error);
        }
    }];
}


@end
