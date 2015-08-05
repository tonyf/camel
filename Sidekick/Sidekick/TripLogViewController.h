//
//  TripLogViewController.h
//  Sidekick
//
//  Created by Tony Francis on 7/20/15.
//  Copyright (c) 2015 thesquad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TripLogManager.h"
#import "TripCell.h"
#import "MenuViewController.h"
#import "MapImageGenerator.h"

@interface TripLogViewController : UIViewController <TripCellDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) MenuViewController *menu;

@end
