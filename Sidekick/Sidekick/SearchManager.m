//
//  SearchManager.m
//  Sidekick
//
//  Created by Tony Francis on 7/14/15.
//  Copyright (c) 2015 thesquad. All rights reserved.
//

#import "SearchManager.h"
#import "VoiceNavigationManager.h"
#import <MapKit/MapKit.h>
#import "WitListener.h"

@interface SearchManager ()

@end

@implementation SearchManager

@synthesize delegate;

+ (SearchManager *)sharedInstance {
    static SearchManager *sharedSearchManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSearchManager = [[self alloc] init];
    });
    return sharedSearchManager;
}

- (instancetype)init {
    if (self = [super init]) {
        [[WitListener sharedInstance] addObserver:self];
    }
    return self;
}

- (void)queryLocationsForString:(NSString *)query region:(MKCoordinateRegion)region {
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = query;
    request.region = region;
    
    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
    
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error)
     {
         if (error) {
             NSLog(@"[Search Manager] %@", error);
         } else {
             [self.delegate presentSearchResults:response.mapItems];
         }
     }];

}

- (void)getLocationFromString:(NSString *)locationString {
    CLLocationDistance distance = 100000;
    CLLocationCoordinate2D userCoordinates = [[VoiceNavigationManager sharedInstance] currentLocation].coordinate;
    CLCircularRegion *searchRegion = [[CLCircularRegion alloc] initWithCenter:userCoordinates radius:distance identifier:@"SearchRegion"];
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:locationString
                          inRegion:searchRegion
                 completionHandler:^(NSArray *placemarks, NSError *error) {
                     
                     CLPlacemark *placemark = placemarks[0];
                     [self.delegate presentSingleSearchResult:placemark];
                 }];
    
}

- (void)endNavigationWithDirection:(ProcessedDirection *)direction {
    [self.delegate endNavigation];
}

- (void)handleRoute:(MKPolyline *)route {
    [self.delegate presentMapRoute:route];
}

- (WITMicButton *)voiceCommandButtonWithRect:(CGRect)rect {
    return [[WITMicButton alloc] initWithFrame:rect];
}


@end
