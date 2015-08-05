//
//  TripLogManager.h
//  Sidekick
//
//  Created by Tony Francis on 7/17/15.
//  Copyright (c) 2015 thesquad. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Trip;

@interface TripLogManager : NSObject

typedef void(^completion)(BOOL);

+ (TripLogManager *)sharedInstance;
- (NSArray *)trips;
- (void)loadTrips:(completion) completion;
- (void)deleteTrip:(Trip *)trip;


@end
