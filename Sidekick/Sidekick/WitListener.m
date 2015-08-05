//
//  WitListener.m
//  Sidekick
//
//  Created by Tony Francis on 7/12/15.
//  Copyright (c) 2015 thesquad. All rights reserved.
//

#import "WitListener.h"

@interface WitListener ()
@property NSMutableArray *listeners;
@end

@implementation WitListener

+ (WitListener *)sharedInstance {
    static WitListener *sharedWitListener = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedWitListener = [[self alloc] init];
    });
    return sharedWitListener;
}

- (instancetype)init {
    if (self = [super init]) {
        [Wit sharedInstance].delegate = self;
        _listeners = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addObserver:(NSObject *)observer {
    [_listeners addObject:observer];
}

- (void)removeObserver:(NSObject *)observer {
    [_listeners removeObject:observer];
}

- (void)witDidGraspIntent:(NSArray *)outcomes messageId:(NSString *)messageId customData:(id)customData error:(NSError *)e {
    if (e) {
        NSLog(@"[Wit] error: %@", e);
    } else {
        NSString *intent = [[outcomes objectAtIndex:0] objectForKey:@"intent"];
        
        if ([intent isEqualToString:@"navigate_places"]) {
            NSArray *resultArray = [[[outcomes objectAtIndex:0] objectForKey:@"entities"] objectForKey:@"location"];
            NSString *location = resultArray.firstObject[@"value"];
            [_listeners enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                SEL selector = NSSelectorFromString(@"getLocationFromString:");
                if ([obj respondsToSelector:selector]) {
                    [obj performSelectorInBackground:selector withObject:location];
                }
            }];
             
        } else if ([intent isEqualToString:@"interpret_mapkit"]) {
            NSArray *directionsArray = [[[outcomes objectAtIndex:0] objectForKey:@"entities"] objectForKey:@"turn_direction"];
            NSArray *streetArray = [[[outcomes objectAtIndex:0] objectForKey:@"entities"] objectForKey:@"location"];
            
            NSString *instruction = [[outcomes objectAtIndex:0] objectForKey:@"_text"];
            NSString *turnDirection = directionsArray.firstObject[@"value"];
            NSString *turnStreet = streetArray.firstObject[@"value"];
            
            ProcessedDirection *direction = [[ProcessedDirection alloc] initWithInstruction:instruction turnDirection:turnDirection street:turnStreet];

            [_listeners enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                SEL turn = NSSelectorFromString(@"handleNavigationDirection:");
                SEL end = NSSelectorFromString(@"endNavigation:");
                
                if ([turnDirection isEqualToString:@"arrive"]) {
                    if ([obj respondsToSelector:end]) {
                        [obj performSelectorInBackground:end withObject:direction];
                    }
                } else {
                    if ([obj respondsToSelector:turn]) {
                        [obj performSelectorInBackground:turn withObject:direction];
                    }
                }
            }];
        }
    }
}

@end
