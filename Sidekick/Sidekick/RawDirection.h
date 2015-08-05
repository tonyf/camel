//
//  Direction.h
//  Sidekick
//
//  Created by Tony Francis on 7/7/15.
//  Copyright (c) 2015 thesquad. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MKPolyline;
@class CLLocation;

@interface RawDirection : NSObject

@property MKPolyline *stepLine;
@property NSString *instruction;
@property CLLocation *location;

- (instancetype)initWithStep:(MKPolyline *)line instruction:(NSString *)instruction location:(CLLocation *)location;

@end
