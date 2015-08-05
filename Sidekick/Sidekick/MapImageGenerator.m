//
//  MapImageGenerator.m
//  Sidekick
//
//  Created by Tony Francis on 7/21/15.
//  Copyright (c) 2015 thesquad. All rights reserved.
//

#import "MapImageGenerator.h"
#import "MapManager.h"
#import <Parse/Parse.h>
#import <MapKit/MapKit.h>

@interface MapImageGenerator ()
@property (nonatomic, strong) NSArray *locations;
@property (nonatomic, strong) MKMapView *map;
@property (nonatomic, strong) MapManager *mapManager;
@end

#define MAP_WIDTH 446
#define MAP_HEIGHT 282

@implementation MapImageGenerator
@synthesize delegate;

- (instancetype)initWithLocations:(NSArray *)locations {
    if (self = [super init]) {
        _locations = locations;
        [self setupMap];
        [self setupRoute];
    }
    return self;
}

- (void)setupMap {
    _map = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, MAP_WIDTH, MAP_HEIGHT)];
    _mapManager = [[MapManager alloc] initWithMap:_map shouldShowUser:NO];
    _map.delegate = _mapManager;
}

- (void)setupRoute {
    unsigned long numberOfCoordinates = ((NSArray *)_locations).count;
        
    CLLocationCoordinate2D coordinates[numberOfCoordinates];
    int i = 0;
    for (PFGeoPoint *geopoint in _locations) {
        coordinates[i] = CLLocationCoordinate2DMake(geopoint.latitude, geopoint.longitude);
        i++;
    }
        
    MKPolyline *route = [MKPolyline polylineWithCoordinates:coordinates count:numberOfCoordinates];
    [_mapManager setRoute:route];
}

- (void)generateMapImage {
    MKMapSnapshotOptions *options = [[MKMapSnapshotOptions alloc] init];
    
    
    options.region = _map.region;
    options.scale = [UIScreen mainScreen].scale;
    options.size = _map.frame.size;
    
    MKMapSnapshotter *snapshotter = [[MKMapSnapshotter alloc] initWithOptions:options];
    [snapshotter startWithCompletionHandler:^(MKMapSnapshot *snapshot, NSError *error) {
        UIImage *image = snapshot.image;
        
        UIGraphicsBeginImageContextWithOptions(image.size, YES, image.scale);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
        
        CGContextSetLineWidth(context,2.0f);
        CGContextBeginPath(context);
        
        
        [image drawAtPoint:CGPointMake(0, 0)];
        MKPolyline *polyline = ((MKPolyline *)_map.overlays.lastObject);
        
        CLLocationCoordinate2D coordinates[[polyline pointCount]];
        [polyline getCoordinates:coordinates range:NSMakeRange(0, [polyline pointCount])];
        
        for(int i=0;i<[polyline pointCount];i++)
        {
            CGPoint point = [snapshot pointForCoordinate:coordinates[i]];
            
            if(i==0)
            {
                CGContextMoveToPoint(context,point.x, point.y);
            }
            else{
                CGContextAddLineToPoint(context,point.x, point.y);
                
            }
        }
        CGContextStrokePath(context);
        
        UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        
        [self.delegate gotImage:finalImage];
    }];
}

@end
