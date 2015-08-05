//
//  MapImageGenerator.h
//  Sidekick
//
//  Created by Tony Francis on 7/21/15.
//  Copyright (c) 2015 thesquad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@protocol MapImageGeneratorDelegate
- (void)gotImage:(UIImage *)image;
@end

@interface MapImageGenerator : NSObject

@property (nonatomic, assign) id delegate;

- (instancetype)initWithLocations:(NSArray *)locations;
- (void)generateMapImage;

@end
