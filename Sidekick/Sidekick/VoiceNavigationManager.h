//
//  VoiceNavigation.h
//  Sidekick
//
//  Created by Tony Francis on 7/7/15.
//  Copyright (c) 2015 thesquad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Wit/Wit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "ProcessedDirection.h"


@protocol VoiceNavigationManagerDelegate

- (void)startNavigationWithInstruction:(NSString *)instruction;
- (void)endNavigation;
- (void)presentNavigationDirection:(ProcessedDirection *)direction;
- (void)presentNextTurnDistance:(CLLocationDistance)distance;

@end

@interface VoiceNavigationManager : NSObject

@property (nonatomic, assign) id delegate;
@property (nonatomic, strong) CLLocation *currentLocation;

typedef void(^locationString)(BOOL success, NSString *location);
- (void)currentLocationAsString:(locationString) locationString;

+ (VoiceNavigationManager *)sharedInstance;

- (void)getDirectionsToLocation:(CLLocation *)destination;
- (void)handleNavigationDirection:(ProcessedDirection *)direction;
- (void)endNavigation;

@end
