//
//  ProcessedDirection.m
//  Sidekick
//
//  Created by Tony Francis on 7/13/15.
//  Copyright (c) 2015 thesquad. All rights reserved.
//

#import "ProcessedDirection.h"

@implementation ProcessedDirection

- (instancetype)initWithInstruction:(NSString *)instruction turnDirection:(NSString *)turnDirection street:(NSString *)turnStreet {
    if (self = [super init]) {
        _instruction = instruction;
        _turnDirection = turnDirection;
        _turnStreet = turnStreet;
    }
    return self;
}

@end
