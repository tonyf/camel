//
//  WitListener.h
//  Sidekick
//
//  Created by Tony Francis on 7/12/15.
//  Copyright (c) 2015 thesquad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Wit/Wit.h>
#import "ProcessedDirection.h"

@interface WitListener : NSObject <WitDelegate>

+ (WitListener *)sharedInstance;
- (void)addObserver:(NSObject *)observer;
- (void)removeObserver:(NSObject *)observer;

@end
