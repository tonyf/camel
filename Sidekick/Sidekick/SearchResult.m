//
//  SearchResult.m
//  Sidekick
//
//  Created by Tony Francis on 7/14/15.
//  Copyright (c) 2015 thesquad. All rights reserved.
//

#import "SearchResult.h"

@implementation SearchResult

- (instancetype)initWithQueryResult:(MKMapItem *)mapItem {
    if (self = [super init]) {
        _title = mapItem.placemark.name;
        _location = mapItem.placemark.location;
        
    }
    return self;
}

- (instancetype)initWithPlacemark:(CLPlacemark *)placemark {
    if (self = [super init]) {
        _title = placemark.name;
        _location = placemark.location;
    }
    return self;
}


@end
