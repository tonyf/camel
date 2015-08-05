// Copyright 2004-present Facebook. All Rights Reserved.


#import <UIKit/UIKit.h>
#import "VoiceNavigationManager.h"
#import <MapKit/MapKit.h>
@class SearchResult;


@interface NavigationViewController : UIViewController <VoiceNavigationManagerDelegate>


@property (weak, nonatomic) IBOutlet UILabel *instructionsLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UIView *navigationBar;

@property BOOL showingNavView;

@end
