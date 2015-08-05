//
//  Trip.h
//  Sidekick
//
//  Created by Tony Francis on 7/17/15.
//  Copyright (c) 2015 thesquad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import <MapKit/MapKit.h>

@interface Trip : PFObject <PFSubclassing>

@property (strong, nonatomic) NSDate *date;
@property (assign, nonatomic) float distance;
@property (assign, nonatomic) float secondsSpentBiking;
@property (strong, nonatomic) NSString *startLocationString;
@property (strong, nonatomic) NSString *endLocationString;
@property (strong, nonatomic) PFGeoPoint *endLocation;

@property (strong, nonatomic) PFFile *mapImage;

@property (strong, nonatomic, readonly) MKPolyline *route;


@end
