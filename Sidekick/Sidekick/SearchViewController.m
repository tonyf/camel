//
//  SearchViewController.m
//  Sidekick
//
//  Created by Tony Francis on 7/14/15.
//  Copyright (c) 2015 thesquad. All rights reserved.
//

#import "SearchViewController.h"
#import <INTULocationManager/INTULocationManager.h>
#import <CSNotificationView/CSNotificationView.h>
#import "VoiceNavigationManager.h"
#import "SearchResult.h"

@interface SearchViewController ()
@property (nonatomic) MKCoordinateRegion region;
@property (nonatomic, strong) MapManager *mapManager;
@property (nonatomic, strong) SearchResult *selectedSearchResult;
@property (nonatomic, copy) NSArray *searchResults;
@end

#define CELL_HEIGHT 44

@implementation SearchViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [SearchManager sharedInstance].delegate = self;
        _searchResults = [[NSArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupMap];
    [self setupSearch];
    [self setupVoiceButton];
    [self requestLocation];
    [self setupGestures];
}

// MARK - Setup Methods

- (void)setupMap {
    _mapManager = [[MapManager alloc] initWithMap:_map shouldShowUser:YES];
    _mapManager.delegate = self;
    _map.delegate = _mapManager;
}

- (void)setupSearch {
    _searchBar.delegate = self;
    _searchResultsTableView.delegate = self;
    _searchResultsTableView.dataSource = self;
    
    _searchBar.backgroundImage = [UIImage new];
    _searchBar.translucent = YES;
    
    UITextField *field = ([(UITextField *)_searchBar valueForKey:@"_searchField"]);
    field.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.25];
    field.textColor = [UIColor whiteColor];
}

- (void)setupVoiceButton {
    UIButton *button = [[SearchManager sharedInstance] voiceCommandButtonWithRect:CGRectMake(0, 0, 42, 42)];
    [_voiceCommandView addSubview:button];
}

- (void)setupGestures {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissSearch)];
    tap.numberOfTapsRequired = 1;
    [_map addGestureRecognizer:tap];
    
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dismissSearch:)];
    swipe.direction = UISwipeGestureRecognizerDirectionDown;
    [_navigationBar addGestureRecognizer:swipe];
}

- (void)requestLocation {
    [[INTULocationManager sharedInstance] requestLocationWithDesiredAccuracy:INTULocationAccuracyCity timeout:10 block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
        MKCoordinateSpan span = MKCoordinateSpanMake(1.5, 1.5);
        _region = MKCoordinateRegionMake(currentLocation.coordinate, span);
    }];
}

// MARK - Search Bar Methods
- (IBAction)endNavigation:(id)sender {
    [self showCommandView];
    [[VoiceNavigationManager sharedInstance] endNavigation];
    [self endNavigation];
}

- (void)dismissSearch {
    [_searchBar resignFirstResponder];
    [self hideTable];
}

- (IBAction)dismissSearch:(UIButton *)sender {
    [self dismissSearch];
    
    SEL selector = NSSelectorFromString(@"dismissSearch:");
    [self.parentViewController performSelectorInBackground:selector withObject:self];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [[SearchManager sharedInstance] queryLocationsForString:searchBar.text region:_region];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self dismissSearch];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [[SearchManager sharedInstance] queryLocationsForString:searchBar.text region:_region];
}

// MARK - Results TableView Animation

- (void)showTable {
    NSInteger height = _searchResults.count * CELL_HEIGHT;
    height = height < 200 ? height : 200;
    [UIView animateWithDuration:0.5f animations:^{
        [_searchResultsTableView setFrame:CGRectMake(_searchResultsTableView.frame.origin.x, _searchResultsTableView.frame.origin.y, self.view.frame.size.width, height)];
    }];
}

- (void)hideTable {
    [UIView animateWithDuration:0.5f animations:^{
        [_searchResultsTableView setFrame:CGRectMake(_searchResultsTableView.frame.origin.x, _searchResultsTableView.frame.origin.y, self.view.frame.size.width, 0)];
    }];
}

// MARK - Results TableView DataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _searchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"resultCell"];
    
    SearchResult *resultItem = ((SearchResult *)[_searchResults objectAtIndex:indexPath.item]);
    cell.textLabel.text = resultItem.title;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SearchResult *selectedItem = ((SearchResult *)[_searchResults objectAtIndex:indexPath.item]);
    _searchBar.text = selectedItem.title;
    
    [_searchBar resignFirstResponder];
    [self hideTable];
    
    [self handleSelectedSearchResult:selectedItem];
}

// MARK - Map Management
#define SWITCH_DURATION 0.5

- (void)showCommandView {
    [UIView animateWithDuration:SWITCH_DURATION animations:^{
        [_voiceCommandView setAlpha:1.0f];
        [_endNavButton setAlpha:0.0f];
        [_voiceCommandView setHidden:NO];
    } completion:^(BOOL finished) {
        [_endNavButton setHidden:YES];
    }];
}

- (void)showEndNavigation {
    [UIView animateWithDuration:SWITCH_DURATION animations:^{
        [_voiceCommandView setAlpha:0.0f];
        [_endNavButton setAlpha:1.0f];
        [_endNavButton setHidden:NO];
    } completion:^(BOOL finished) {
        [_voiceCommandView setHidden:YES];
    }];
}

- (void)navigateForCurrentPin {
    [self showEndNavigation];
    [[VoiceNavigationManager sharedInstance] getDirectionsToLocation:_selectedSearchResult.location];
}

- (void)endNavigation {
    [_mapManager clearMap];
}

- (void)presentMapRoute:(MKPolyline *)route {
    CLLocationCoordinate2D destinationCoordinate;
    [route getCoordinates:&destinationCoordinate range:NSMakeRange(route.pointCount - 1, route.pointCount)];
    
    MKPointAnnotation *pin = [[MKPointAnnotation alloc] init];
    [pin setCoordinate:destinationCoordinate];

    [_mapManager setPin:pin];
    [_mapManager setRoute:route];
    [_mapManager startNavigation];
}

// MARK - Search Results

- (void)presentSearchResults:(NSArray *)results {
    NSMutableArray *searchResults = [[NSMutableArray alloc] init];
    for (MKMapItem *item in results) {
        SearchResult *result = [[SearchResult alloc] initWithQueryResult:item];
        [searchResults addObject:result];
    }
    _searchResults = searchResults;
    [_searchResultsTableView reloadData];
    [self showTable];
}

- (void)presentSingleSearchResult:(CLPlacemark *)placemark {
    if (placemark) {
        _selectedSearchResult = [[SearchResult alloc] initWithPlacemark:placemark];
        
        MKPointAnnotation *annotationPin = [[MKPointAnnotation alloc] init];
        [annotationPin setCoordinate:_selectedSearchResult.location.coordinate];
        [annotationPin setTitle:_selectedSearchResult.title];
        
        [_mapManager clearMap];
        [_mapManager setPin:annotationPin];
    } else {
        [CSNotificationView showInViewController:self
                                           style:CSNotificationViewStyleError
                                         message:@"Location not found."];
    }
}

- (void)handleSelectedSearchResult:(SearchResult *)result {
    _selectedSearchResult = result;

    MKPointAnnotation *annotationPin = [[MKPointAnnotation alloc] init];
    [annotationPin setCoordinate:result.location.coordinate];
    [annotationPin setTitle:result.title];
    
    [_mapManager clearMap];
    [_mapManager setPin:annotationPin];
}


@end
