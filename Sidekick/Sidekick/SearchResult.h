//
//  SearchResult.h
//  Sidekick
//
//  Created by Tony Francis on 7/14/15.
//  Copyright (c) 2015 thesquad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface SearchResult : NSObject

@property NSString *title;
@property CLLocation *location;

- (instancetype)initWithQueryResult:(MKMapItem *)mapItem;
- (instancetype)initWithPlacemark:(CLPlacemark *)placemark;

@end
