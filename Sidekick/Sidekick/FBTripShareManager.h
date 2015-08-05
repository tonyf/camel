//
//  FBTripShareManager.h
//  Sidekick
//
//  Created by Bernard Snowden on 7/23/15.
//  Copyright (c) 2015 thesquad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIKit/UIKit.h"

@class FBSDKSharePhoto;
@class Trip;

@interface FBTripShareManager : NSObject

- (void)shareTrip:(Trip *)trip AndMapImageToTimeline:(UIImage *)mapImage fromVC:(UIViewController *)mvc;

@end

