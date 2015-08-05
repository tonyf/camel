//
//  RearCameraViewController.h
//  Sidekick
//
//  Created by Kathleen Feng on 7/6/15.
//  Copyright (c) 2015 thesquad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoFeedViewController.h"
#import <opencv2/videoio/cap_ios.h>
@class DraggableView;

@interface RearCameraViewController : VideoFeedViewController <CvVideoCameraDelegate, UITableViewDelegate, UITableViewDataSource>

@property cv::CascadeClassifier carCascade;

@property (nonatomic, strong) IBOutlet UIView *translucentView;
@property (nonatomic, strong) DraggableView *slideView;

@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic,strong) UIButton *menuButton;
@property (strong, nonatomic) UIVisualEffectView *blurView;

@property (nonatomic,retain) NSArray * menuItems;
@property (nonatomic, strong) UITableView *viewForTable;

@property (nonatomic, strong) UIView *viewForMenu;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;



- (void)setupMenuView;
- (void)showMenu:(BOOL)yesNo;
- (void)menuAction;
- (void)closeMenu;

@end
