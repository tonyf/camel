//
//  VoiceNavigation.m
//  Sidekick
//
//  Created by Tony Francis on 7/7/15.
//  Copyright (c) 2015 thesquad. All rights reserved.
//

#import "VoiceNavigationManager.h"
#import <INTULocationManager/INTULocationManager.h>
#import <MapKit/MapKit.h>
#import "RawDirection.h"
#import "ProcessedDirection.h"
#import "WitListener.h"
#import "SearchManager.h"
#import <Tweaks/FBTweak.h>
#import <Tweaks/FBTweakShakeWindow.h>
#import <Tweaks/FBTweakInline.h>
#import <Tweaks/FBTweakViewController.h>

@interface VoiceNavigationManager ()
@property (nonatomic) INTULocationRequestID locationRequestID;

@property BOOL navInProcess;

@property (nonatomic, strong) CLLocation *destination;

@property (nonatomic, strong) NSMutableArray *directions;

@property (nonatomic, readonly) CLLocationDistance maxSearchDistance;
@property (nonatomic, readonly) CLLocationDistance pointRadius;
@property (nonatomic, readonly) CLLocationDistance routeTrackingRadius;

@property (nonatomic, strong) NSString *distanceString;
@property (nonatomic, strong) NSString *radiusString;
@property (nonatomic, strong) NSString *trackingRadiusString;

@end

@implementation VoiceNavigationManager

@synthesize delegate;

+ (VoiceNavigationManager *)sharedInstance {
    static VoiceNavigationManager *sharedVoiceNavigationManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedVoiceNavigationManager = [[self alloc] init];
    });
    return sharedVoiceNavigationManager;
}

- (instancetype)init {
    if (self = [super init]) {
        [[WitListener sharedInstance] addObserver:self];
        [self updateLocationContinuously];
        _directions = [[NSMutableArray alloc] init];
        
        [self initNavigationWithFBTweaks];
        
    }
    return self;
}

- (void)currentLocationAsString:(locationString)locationString {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:_currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error) {
            NSLog(@"[Geocoder] Could not reverse geocode: %@", error);
        } else {
            MKPlacemark *placemark = placemarks.firstObject;
            NSString *string = placemark.locality;
            locationString(YES, string);
        }
    }];
}

- (void)initNavigationWithFBTweaks {
    
    _distanceString = FBTweakValue(@"Voice Navigation", @"Distance Controls", @"Max Search Distance", @"100 miles");
    _maxSearchDistance = [[[MKDistanceFormatter alloc] init] distanceFromString:_distanceString];
    
    _radiusString = @"400 feet";
    _pointRadius = [[[MKDistanceFormatter alloc] init] distanceFromString:_radiusString];
    
    _trackingRadiusString = FBTweakValue(@"Voice Navigation", @"Distance Controls", @"Route Tracking Radius", @"1 mile");
    _routeTrackingRadius = [[[MKDistanceFormatter alloc] init] distanceFromString:_trackingRadiusString];
}

- (void)endNavigation {
    [self.delegate endNavigation];
    [_directions removeAllObjects];
}

- (void)handleNavigationDirection:(ProcessedDirection *)direction {
    [self.delegate presentNavigationDirection:direction];
}

- (void)getDirectionsToLocation:(CLLocation *)destination {
    // Create start point
    MKPlacemark *startPlacemark = [[MKPlacemark alloc] initWithCoordinate:_currentLocation.coordinate
                                                        addressDictionary:nil];
    MKMapItem *startMapItem = [[MKMapItem alloc] initWithPlacemark:startPlacemark];
    
    // Create end point
    MKPlacemark *endPlacemark = [[MKPlacemark alloc] initWithCoordinate:destination.coordinate
                                                      addressDictionary:nil];
    MKMapItem *endMapItem = [[MKMapItem alloc] initWithPlacemark:endPlacemark];
    
    // Create request with points
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    [request setSource:startMapItem];
    [request setDestination:endMapItem];
    request.requestsAlternateRoutes = NO;
    request.transportType = MKDirectionsTransportTypeWalking;
    
    // Get directions from Apple
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        if (error) {
            NSLog(@"[Map] error: %@", error);
        } else {
            NSLog(@"Got directions");
            [self.delegate startNavigationWithInstruction:((RawDirection *)_directions.lastObject).instruction];
            _destination = destination;
            
            for (MKRoute *route in response.routes) {
                [[SearchManager sharedInstance] handleRoute:route.polyline];
                for (MKRouteStep *step in [route.steps reverseObjectEnumerator]) {
                    MKMapPoint turnPoint = step.polyline.points[step.polyline.pointCount - 1];
                    CLLocationCoordinate2D coordinates = MKCoordinateForMapPoint(turnPoint);
                    CLLocation *turn = [[CLLocation alloc] initWithLatitude:coordinates.latitude longitude:coordinates.longitude];
                    
                    RawDirection *nextDirection = [[RawDirection alloc] initWithStep:step.polyline instruction:step.instructions location:turn];
                    
                    [_directions addObject:nextDirection];
                }
            }
            [self.delegate startNavigationWithInstruction:((RawDirection *)_directions.lastObject).instruction];
        }
    }];
}

- (void)updateLocationContinuously {
    _locationRequestID = [[INTULocationManager sharedInstance] subscribeToLocationUpdatesWithBlock:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
        if (status == INTULocationStatusSuccess) {
            if (!_currentLocation) {
                _currentLocation = currentLocation;
            }
                _currentLocation = currentLocation;
                RawDirection *nextDirection = (RawDirection *)_directions.lastObject;
                
                if (nextDirection) {
                    CLLocationDistance distance = [currentLocation distanceFromLocation:nextDirection.location];
                    if (achievedAccuracy > INTULocationAccuracyBlock) {
                        [self.delegate presentNextTurnDistance:distance];
                    }
                    if ([currentLocation distanceFromLocation:nextDirection.location] <= _pointRadius) {
                        NSLog(@"%@", nextDirection.instruction);
                        _routeTrackingRadius = [currentLocation distanceFromLocation:nextDirection.location] * 3/2;
                        ProcessedDirection *direction = [[ProcessedDirection alloc] init];
                        direction.instruction = nextDirection.instruction;
                        [self.delegate presentNavigationDirection:direction];
                        //[[Wit sharedInstance] interpretString:nextDirection.instruction customData:nil];
                        [_directions removeLastObject];
                    } else {
                        [self recalculateIfNecessaryAtRoutePolyLine:nextDirection.stepLine
                                                    currentLocation:_currentLocation];
                    }
            }
        }
         else {
            NSLog(@"[Location] error: %ld", (long)status);
        }
    }];
}

- (void)recalculateIfNecessaryAtRoutePolyLine:(MKPolyline *)stepLine currentLocation:(CLLocation *)currentLocation {
    BOOL userOnRoute = NO;

    for (int i = 0; i < stepLine.pointCount; i++) {
        CLLocationCoordinate2D routePointCoordinates = MKCoordinateForMapPoint(stepLine.points[i]);
        CLLocation *routePointLocation = [[CLLocation alloc] initWithLatitude:routePointCoordinates.latitude
                                                                    longitude:routePointCoordinates.longitude];
        if ([currentLocation distanceFromLocation:routePointLocation] <= _routeTrackingRadius) {
            userOnRoute = YES;
            break;
        }
    }

    if (!userOnRoute && _directions.count > 0) {
        NSLog(@"Recalculating");
        _directions = [[NSMutableArray alloc] init];
        [self getDirectionsToLocation:_destination];
    }
}

@end
