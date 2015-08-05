//
//  AlertPlayer.h
//  Sidekick
//
//  Created by Kathleen Feng on 7/23/15.
//  Copyright (c) 2015 thesquad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface AlertPlayer : NSObject

+ (AlertPlayer *)sharedInstance;
- (void)play;
- (void)changeAlert;

@end
