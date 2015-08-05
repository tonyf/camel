//
//  Direction.m
//  Sidekick
//
//  Created by Tony Francis on 7/7/15.
//  Copyright (c) 2015 thesquad. All rights reserved.
//

#import "RawDirection.h"

@implementation RawDirection

- (instancetype)initWithStep:(MKPolyline *)line instruction:(NSString *)instruction location:(CLLocation *)location {
    if (self = [super init]) {
        _stepLine = line;
        _instruction = instruction;
        _location = location;
    }
    return self;
}

@end
