//
//  SearchViewController.h
//  Sidekick
//
//  Created by Tony Francis on 7/14/15.
//  Copyright (c) 2015 thesquad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchManager.h"
#import "MapManager.h"

@interface SearchViewController : UIViewController <UISearchBarDelegate, SearchManagerDelegate, UITableViewDelegate, UITableViewDataSource, MapManagerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *map;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *searchResultsTableView;
@property (weak, nonatomic) IBOutlet UIView *voiceCommandView;
@property (weak, nonatomic) IBOutlet UIButton *endNavButton;
@property (weak, nonatomic) IBOutlet UIView *navigationBar;

@end
