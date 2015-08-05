//
//  MapManager.m
//  Sidekick
//
//  Created by Tony Francis on 7/20/15.
//  Copyright (c) 2015 thesquad. All rights reserved.
//

#import "MapManager.h"

@interface MapManager ()
@property (nonatomic, strong) MKPolyline *route;
@property (nonatomic, strong) MKPointAnnotation *pin;
@end

#define MINIMUM_ZOOM_ARC 0.014
#define ANNOTATION_REGION_PAD_FACTOR 3
#define MAX_DEGREES_ARC 360

@implementation MapManager

- (instancetype)initWithMap:(MKMapView *)map shouldShowUser:(BOOL)shouldShowUser {
    if (self = [super init]) {
        _map = map;
        if (shouldShowUser) {
            [_map setUserTrackingMode:MKUserTrackingModeFollow animated:NO];
        }
    }
    return self;
}

- (void)clearMap {
    [_map removeOverlay:_route];
    [_map removeAnnotation:_pin];
    
    _route = nil;
    _pin = nil;
}

- (void)setRoute:(MKPolyline *)route {
    [_map removeOverlay:_route];
    _route = nil;
    [_map addOverlay:route];
    _route = route;
    [self adjustMapView];
}

- (void)setPin:(MKPointAnnotation *)pin {
    [_map removeAnnotation:_pin];
    _pin = nil;
    [_map addAnnotation:pin];
    _pin = pin;
    [self adjustMapView];
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    MKPolylineRenderer *render = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
    render.strokeColor = [UIColor blueColor];
    render.lineWidth = 3;
    return render;
}

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if([annotation isKindOfClass: [MKUserLocation class]]) {
        return nil;
    }
    
    MKPinAnnotationView *pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@""];
    pinView.pinColor = MKPinAnnotationColorRed;
    pinView.animatesDrop = YES;
    pinView.canShowCallout = YES;
    pinView.tintColor = [UIColor blueColor];
    
    UIButton *navButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    navButton.frame = CGRectMake(0, 3, 10, pinView.frame.size.height - 10);
    UIImage *image = [UIImage imageNamed:@"start_nav"];
    navButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    navButton.tintColor = [UIColor lightGrayColor];
    [navButton setImage:image forState:UIControlStateNormal];
    
    [navButton addTarget:self.delegate action:@selector(navigateForCurrentPin) forControlEvents:UIControlEventTouchUpInside];
    pinView.rightCalloutAccessoryView = navButton;
    
    UIImageView *bikeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, pinView.frame.size.height + 10, pinView.frame.size.height + 10)];
    bikeImageView.contentMode = UIViewContentModeScaleAspectFill;
    [bikeImageView setImage:[UIImage imageNamed:@"bike_callout"]];
    pinView.leftCalloutAccessoryView = bikeImageView;
    
    return pinView;
}

- (void)adjustMapView {
    if (_map.annotations.count == 0 && !_route) {
        return;
    }
    
    MKMapPoint points[2];
    MKMapRect mapRect;
    BOOL animate = YES;
    if (_map.annotations.count > 0) {
        points[0] = MKMapPointForCoordinate(_pin.coordinate);
        points[1] = MKMapPointForCoordinate(_map.userLocation.coordinate);
        mapRect = [[MKPolygon polygonWithPoints:points count:2] boundingMapRect];
        
    } else {
        animate = NO;
        mapRect = [[MKPolygon polygonWithPoints:_route.points count:_route.pointCount] boundingMapRect];
    }
    
    MKCoordinateRegion region = MKCoordinateRegionForMapRect(mapRect);
    region.span.latitudeDelta  *= ANNOTATION_REGION_PAD_FACTOR;
    region.span.longitudeDelta *= ANNOTATION_REGION_PAD_FACTOR;
    
    if (region.span.latitudeDelta > MAX_DEGREES_ARC) { region.span.latitudeDelta  = MAX_DEGREES_ARC; }
    if (region.span.longitudeDelta > MAX_DEGREES_ARC) { region.span.longitudeDelta = MAX_DEGREES_ARC; }
    
    if (region.span.latitudeDelta  < MINIMUM_ZOOM_ARC ) { region.span.latitudeDelta  = MINIMUM_ZOOM_ARC; }
    if (region.span.longitudeDelta < MINIMUM_ZOOM_ARC ) { region.span.longitudeDelta = MINIMUM_ZOOM_ARC; }
    
    if (_map.annotations.count == 1) {
        region.span.latitudeDelta = MINIMUM_ZOOM_ARC;
        region.span.longitudeDelta = MINIMUM_ZOOM_ARC;
    }
    
    
    [_map setRegion:region animated:animate];
}

- (void)startNavigation {
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    
    span.latitudeDelta = 0.005;
    span.longitudeDelta = 0.005;
    
    region.span = span;
    region.center = _map.userLocation.coordinate;
    
    //[_map setRegion:region animated:YES];
}

@end
