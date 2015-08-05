//
//  TripLogViewController.m
//  Sidekick
//
//  Created by Tony Francis on 7/20/15.
//  Copyright (c) 2015 thesquad. All rights reserved.
//

#import "TripLogViewController.h"
#import "TripCell.h"
#import "Trip.h"
#import <Parse/Parse.h>
#import "VoiceNavigationManager.h"
#import "FBTripShareManager.h"
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <FBSDKShareKit/FBSDKShareKit.h>


@interface TripLogViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) NSMutableArray *trips;
@property FBTripShareManager *shareManager;
@property (strong, nonatomic) MapImageGenerator *mapImageGenerator;
@property (weak, nonatomic) IBOutlet UILabel *emptyLogLabel;

@end

static NSString *CellIdentifier = @"TripCell";

@implementation TripLogViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _mapImageGenerator = [[MapImageGenerator alloc]init];
        _mapImageGenerator.delegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _loadTrips];
    [self _setupButton];
    [self _setupTableView];
    self.shareManager = [[FBTripShareManager alloc]init];
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
}

- (void)_setupTableView {
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerNib:[UINib nibWithNibName:@"TripCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
    _tableView.delaysContentTouches = NO;
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(reloadData:) forControlEvents:UIControlEventValueChanged];
    [_tableView addSubview:refreshControl];
}

- (void)_setupButton {
    UIImage *closeImage = [UIImage imageNamed:@"closeSearch"];
    CGRect frame = CGRectMake(0, 0, 22, 15);

    UIButton *button = [[UIButton alloc] initWithFrame:frame];
    [button setBackgroundImage:closeImage forState:UIControlStateNormal];
    [button setShowsTouchWhenHighlighted:YES];
    [button addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchDown];

    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationBar.topItem.leftBarButtonItem = closeButton;
}

- (void)dismiss {
    [_menu dismissViewControllerAnimated:YES completion:nil];
}

- (void)_loadTrips {
    [[TripLogManager sharedInstance] loadTrips:^(BOOL finished) {
        if (finished) {
            _trips = [[NSMutableArray alloc] init];
            for (Trip *trip in [TripLogManager sharedInstance].trips) {
                if (trip.endLocationString.length > 0) {
                    [_trips addObject:trip];
                }
            }
            [_tableView reloadData];
            NSLog(@"Did reload");
        }
    }];
}

- (void)reloadData:(UIRefreshControl *)refreshContol {
    [[TripLogManager sharedInstance] loadTrips:^(BOOL finished) {
        if (finished) {
            _trips = [[NSMutableArray alloc] init];
            for (Trip *trip in [TripLogManager sharedInstance].trips) {
                if (trip.endLocationString.length > 0) {
                    [_trips addObject:trip];
                }
            }
            [_tableView reloadData];
            [refreshContol endRefreshing];
        }
    }];
}

- (void)startButtonWasPressedForCellAtIndexPath:(NSIndexPath *)indexPath {
    Trip *trip = _trips[indexPath.item];
    CLLocation *destination = [[CLLocation alloc] initWithLatitude:trip.endLocation.latitude longitude:trip.endLocation.longitude];
    
    [[VoiceNavigationManager sharedInstance] getDirectionsToLocation:destination];
    [self dismiss];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_trips.count > 0) {
        _emptyLogLabel.hidden = YES;
    } else {
        _emptyLogLabel.hidden = NO;
    }
    return _trips.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TripCell *cell = ((TripCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath]);
    Trip *trip = _trips[indexPath.item];
    
    cell.startLocation.text = trip.startLocationString;
    cell.endLocation.text = trip.endLocationString;

    cell.delegate = self;
    cell.indexPath = indexPath;

    [trip.mapImage getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
        if (!error) {
            UIImage *mapImage = [UIImage imageWithData:imageData];
            cell.mapImageView.clipsToBounds = YES;
            [cell.mapImageView setImage:mapImage];
        }
    }];

    CLLocationDistance distance = trip.distance;
    MKDistanceFormatter *formatter = [[MKDistanceFormatter alloc] init];
    cell.distanceLabel.text = [formatter stringFromDistance:distance];

    NSDateComponentsFormatter *dcFormatter = [[NSDateComponentsFormatter alloc] init];
    dcFormatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorPad;
    dcFormatter.allowedUnits = NSCalendarUnitHour | NSCalendarUnitMinute;
    dcFormatter.unitsStyle = NSDateComponentsFormatterUnitsStyleAbbreviated;
    cell.timeLabel.text = [dcFormatter stringFromTimeInterval:trip.secondsSpentBiking];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterShortStyle;
    cell.dateLabel.text = [dateFormatter stringFromDate:trip.date];

    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    TripCell *cell = ((TripCell *) [tableView cellForRowAtIndexPath:indexPath]);
    [cell hideOptions];
    return YES;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[TripLogManager sharedInstance] deleteTrip:_trips[indexPath.item]];
        [_trips removeObject:_trips[indexPath.item]];
        [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 282;
}

- (void)shareButtonWasPressedForCellAtIndexPath:(NSIndexPath *)indexPath {
    // Request new Publish Permissions
    Trip *trip = _trips[indexPath.item];
    
    [trip.mapImage getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
        if (!error) {
            UIImage *mapImage = [UIImage imageWithData:imageData];
            [self.shareManager shareTrip:trip AndMapImageToTimeline:mapImage fromVC:self];
        }
    }];
}

@end
