//
//  SearchManager.h
//  Sidekick
//
//  Created by Tony Francis on 7/14/15.
//  Copyright (c) 2015 thesquad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
@class ProcessedDirection;
@class WITMicButton;

@protocol SearchManagerDelegate

- (void)presentSearchResults:(NSArray *)results;
- (void)presentSingleSearchResult:(CLPlacemark *)placemark;
- (void)endNavigation;
- (void)presentMapRoute:(MKPolyline *)route;

@end

@interface SearchManager : NSObject

@property (nonatomic, assign) id delegate;

+ (SearchManager *)sharedInstance;

- (void)queryLocationsForString:(NSString *)query
                         region:(MKCoordinateRegion)region;
- (void)getLocationFromString:(NSString *)locationString;
- (void)endNavigationWithDirection:(ProcessedDirection *)direction;
- (void)handleRoute:(MKPolyline *)route;

- (WITMicButton *)voiceCommandButtonWithRect:(CGRect)rect;


@end
