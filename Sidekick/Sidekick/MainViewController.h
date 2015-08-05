//
//  MainViewController.h
//  Sidekick
//
//  Created by Bernard Snowden on 7/13/15.
//  Copyright (c) 2015 thesquad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoFeedManager.h"

@class ImageProcessingViewController;
@class NavigationViewController;
@class MenuViewController;

@interface MainViewController : UIViewController

- (void)showSearch:(NSObject *)sender;
- (void)dismissSearch:(NSObject *)sender;

@end