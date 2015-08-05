//
//  SessionManager.h
//  Sidekick
//
//  Created by Kathleen Feng on 7/17/15.
//  Copyright (c) 2015 thesquad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MapImageGenerator.h"

@protocol SessionManagerDelegate <NSObject>

@end

@interface SessionManager : NSObject <MapImageGeneratorDelegate>

+ (SessionManager *)sharedInstance;
- (void)sessionStarted;
- (void)sessionPaused;
- (void)sessionStopped;
- (void)saveSession;
- (float)secondsSpentBiking;

@end
