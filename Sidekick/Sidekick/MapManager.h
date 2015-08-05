//
//  MapManager.h
//  Sidekick
//
//  Created by Tony Francis on 7/20/15.
//  Copyright (c) 2015 thesquad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@protocol MapManagerDelegate

- (void)navigateForCurrentPin;

@end

@interface MapManager : NSObject <MKMapViewDelegate>
@property (nonatomic, assign) id delegate;
@property (nonatomic, weak) MKMapView *map;

- (instancetype)initWithMap:(MKMapView *)map shouldShowUser:(BOOL)shouldShowUser;
- (void)clearMap;
- (void)setRoute:(MKPolyline *)route;
- (void)setPin:(MKPointAnnotation *)pin;
- (void)startNavigation;
@end
