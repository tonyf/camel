//
//  TripCell.h
//  Sidekick
//
//  Created by Tony Francis on 7/20/15.
//  Copyright (c) 2015 thesquad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Mapkit/MapKit.h>
#import <Parse/Parse.h>
#import "MapManager.h"
@class TripCell;

@protocol TripCellDelegate <NSObject>

- (void)startButtonWasPressedForCellAtIndexPath:(NSIndexPath *)indexPath;
- (void)shareButtonWasPressedForCellAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface TripCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *mapImageView;
@property (weak, nonatomic) IBOutlet UILabel *startLocation;
@property (weak, nonatomic) IBOutlet UILabel *endLocation;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (weak, nonatomic) IBOutlet UIView *infoView;
@property (weak, nonatomic) IBOutlet UIButton *startRouteButton;
@property (weak, nonatomic) IBOutlet UIButton *shareRouteButton;
@property (strong, nonatomic) MapManager *mapManager;

@property (nonatomic, assign) id delegate;
@property (nonatomic, strong) NSIndexPath *indexPath;

- (void)showOptions;
- (void)hideOptions;

@end
