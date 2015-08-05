//
//  SessionManager.m
//  Sidekick
//
//  Created by Kathleen Feng on 7/17/15.
//  Copyright (c) 2015 thesquad. All rights reserved.
//

#import "SessionManager.h"
#import "Trip.h"
#import "MapManager.h"
#import <INTULocationManager/INTULocationManager.h>

@interface SessionManager ()

@property (nonatomic, assign) BOOL sessionBegan;
@property (nonatomic, assign) BOOL sessionOnPause;
@property (nonatomic, strong) NSDate *lastDateRecorded;
@property (nonatomic, strong) NSDate *firstDate;
@property (nonatomic, assign) float secondsElapsed;
@property (nonatomic, assign) CLLocationDistance distance;
@property (nonatomic, strong) NSMutableArray *locations;

@property (nonatomic) INTULocationRequestID locationSubscription;
@property (nonatomic, strong) Trip *trip;

- (void)_resetValues;

@end

#define MAP_WIDTH 446
#define MAP_HEIGHT 282

@implementation SessionManager

+ (SessionManager *)sharedInstance {
    static SessionManager *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[SessionManager alloc] init];
    });
    
    return _sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _sessionBegan = NO;
        _sessionOnPause = NO;
        _lastDateRecorded = nil;
        _secondsElapsed = 0;
        _distance = 0;
        _firstDate = nil;
        _locations = nil;
    }
    return self;
}

- (void)sessionStarted {
    if (!_sessionBegan) {
        _lastDateRecorded = [[NSDate alloc] init];
        _firstDate = _lastDateRecorded;
        _sessionBegan = YES;
        
        _locations = [[NSMutableArray alloc] init];
        [Trip load];
        _trip = [Trip object];
        [_trip saveInBackground];
        
        _locationSubscription = [[INTULocationManager sharedInstance] subscribeToLocationUpdatesWithBlock:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
            if (status == INTULocationStatusSuccess && !_sessionOnPause) {
                PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLocation:currentLocation];
                [_locations addObject:geoPoint];
                if (_locations.count > 1) {
                    _distance += 1000 * [geoPoint distanceInKilometersTo:_locations[_locations.count - 2]];
                }
                
            } else {
                NSLog(@"Not able to update location");
            }
        }];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NewSessionBegan" object:nil];
    } else if (_sessionOnPause) {
        _lastDateRecorded = [[NSDate alloc] init];
        _sessionOnPause = NO;
    }
}

- (void)sessionPaused {
    if (_sessionBegan && !_sessionOnPause) {
        NSTimeInterval seconds = _lastDateRecorded.timeIntervalSinceNow;
        
        // Subtracting because timeIntervalSinceNow will return a negative number
        _secondsElapsed -= seconds;
        
        _sessionOnPause = YES;
    }
}

- (void)sessionStopped {
    if (_sessionBegan) {
        [[INTULocationManager sharedInstance] cancelLocationRequest:_locationSubscription];
        
        if (!_sessionOnPause) {
            NSTimeInterval seconds = _lastDateRecorded.timeIntervalSinceNow;
            
            // Subtracting because timeIntervalSinceNow will return a negative number
            _secondsElapsed -= seconds;
        }
        
        if (_locations.count > 0 && _secondsElapsed > 30) {
            MapImageGenerator *imageGenerator = [[MapImageGenerator alloc] initWithLocations:_locations];
            imageGenerator.delegate = self;
            [imageGenerator generateMapImage];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"CurrentSessionDiscarded" object:nil];
            [self _resetValues];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CurrentSessionStopped" object:nil];
    }
}

- (void)gotImage:(UIImage *)image {
    NSData *imageData = UIImagePNGRepresentation(image);
    PFFile *imageFile = [PFFile fileWithName:@"mapImage.png" data:imageData];
    _trip.mapImage = imageFile;
    [self saveSession];
}

- (void)_resetValues {
    _sessionBegan = NO;
    _sessionOnPause = NO;
    _lastDateRecorded = nil;
    _secondsElapsed = 0;
    _distance = 0;
    _firstDate = 0;
    _locations = nil;
}

- (void)saveSession {
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        PFRelation *relation = [currentUser relationForKey:@"trips"];
        
        _trip.date = _firstDate;
        _trip.secondsSpentBiking = _secondsElapsed;
        _trip.distance = _distance;
        
        // Getting city for the start location
        PFGeoPoint *startPoint = _locations.firstObject;
        CLLocation *startLocation = [[CLLocation alloc] initWithLatitude:startPoint.latitude longitude:startPoint.longitude];
        
        CLGeocoder *startGeocoder = [[CLGeocoder alloc] init];
        [startGeocoder reverseGeocodeLocation:startLocation completionHandler:^(NSArray *placemarks, NSError *error) {
            if (error) {
                NSLog(@"[Geocoder] Could not reverse geocode: %@", error);
            } else {
                MKPlacemark *placemark = placemarks.firstObject;
                _trip.startLocationString = placemark.locality;
                [_trip saveInBackground];
            }
        }];
        
        // Getting city for the end location
        _trip.endLocation = _locations.lastObject;
        CLLocation *endLocation = [[CLLocation alloc] initWithLatitude:_trip.endLocation.latitude longitude:_trip.endLocation.longitude];
        
        CLGeocoder *endGeocoder = [[CLGeocoder alloc] init];
        [endGeocoder reverseGeocodeLocation:endLocation completionHandler:^(NSArray *placemarks, NSError *error) {
            if (error) {
                NSLog(@"[Geocoder] Could not reverse geocode: %@", error);
            } else {
                MKPlacemark *placemark = placemarks.firstObject;
                _trip.endLocationString = placemark.locality;
                [_trip saveInBackground];
            }
        }];
        
        [_trip saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                NSLog(@"[Session Manager] Trip saved");
                [[NSNotificationCenter defaultCenter] postNotificationName:@"CurrentSessionSaved" object:nil];
            } else {
                NSLog(@"[Session Manager] %@", error);
            }
        }];
        
        [relation addObject:_trip];
        
        [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                NSLog(@"[Session Manager] Trip relation created");
                
                [self _resetValues];
                
            } else {
                NSLog(@"[Session Manager] Failed to create trip relation: %@", error);
                
                [self _resetValues];
            }
        }];
    }
}

- (float)secondsSpentBiking {
    if (_sessionBegan && !_sessionOnPause) {
        NSTimeInterval seconds = _lastDateRecorded.timeIntervalSinceNow;
        
        // Subtracting because timeIntervalSinceNow will return a negative number
        _secondsElapsed -= seconds;
        
        _lastDateRecorded = [[NSDate alloc] init];
    }
    return _secondsElapsed;
}

@end
