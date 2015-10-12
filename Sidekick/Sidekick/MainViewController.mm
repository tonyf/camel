//
//  MainViewController.m
//  Sidekick
//
//  Created by Bernard Snowden on 7/13/15.
//  Copyright (c) 2015 thesquad. All rights reserved.
//

#import <Tweaks/FBTweak.h>
#import <Tweaks/FBTweakShakeWindow.h>
#import <Tweaks/FBTweakInline.h>
#import <Tweaks/FBTweakViewController.h>

#import "MainViewController.h"
#import "ImageProcessingViewController.h"
#import "SearchViewController.h"
#import "NavigationViewController.h"
#import "SWRevealViewController.h"
#import "FBSDKCoreKit/FBSDKCoreKit.h"
#import "FBSDKLoginKit/FBSDKLoginKit.h"
#import <CSNotificationView/CSNotificationView.h>
#import "MenuViewController.h"
#import "SessionManager.h"
#import "Parse/Parse.h"
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>

@interface MainViewController () <FBTweakViewControllerDelegate, SWRevealViewControllerDelegate>

@property (nonatomic, strong) NavigationViewController *nvc;
@property (nonatomic, strong) ImageProcessingViewController *impvc;
@property (nonatomic, strong) SearchViewController *svc;
@property (nonatomic, strong) NSURL *profilePicURL;
@property (nonatomic, strong) UIImage *profilePic;
@property (nonatomic, strong) UIButton *revealButton;
@property (nonatomic, strong) UILabel *timeSpentBikingLabel;
@property (nonatomic, assign) BOOL showingProfilePic;

- (void)_revealMenu;
- (void)_setupImageProcessingView;
- (void)_setupNavView;
- (void)_setupSearchView;
- (void)_setupRevealMenu;
- (void)_setupFBTweaks;
- (void)_FBTweaksButtonTapped;
- (void)_setupTimeSpentBikingLabel;
- (void)_showUpdatedTime;
- (void)_sessionSaved;
- (void)_sessionStopped;
- (void)_sessionStarted;
- (void)_changeRevealButtonPic;
- (void)_setConstraintsProgramatically;

@end

#define LEFT_PANEL_TAG 2
#define SLIDE_TIMING .45
#define PANEL_WIDTH 667
#define NAVIGATION_BAR_HEIGHT 66
#define PROFILE_PIC_SIZE 60
#define PROFILE_PIC_ORIGIN 30
#define TIME_LABEL_HEIGHT 30
#define TIME_LABEL_WIDTH 97

@implementation MainViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(_sessionStarted) name:@"NewSessionBegan" object:nil];
        [nc addObserver:self selector:@selector(_sessionStopped) name:@"CurrentSessionStopped" object:nil];
        [nc addObserver:self selector:@selector(_sessionDiscarded) name:@"CurrentSessionDiscarded" object:nil];
        [nc addObserver:self selector:@selector(_sessionSaved) name:@"CurrentSessionSaved" object:nil];
        [nc addObserver:self selector:@selector(_changeRevealButtonPic) name:@"MenuViewControllerHidden" object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self _setupImageProcessingView];
    [self _setupNavView];
    [self _setupSearchView];
    [self _setupGestureRecognizers];
    [self _setupRevealMenu];
    [self _setupTimeSpentBikingLabel];
    [self _showUpdatedTime];

    #if DEBUG
    [self _setupFBTweaks];
    #endif
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self _setConstraintsProgramatically];
}

- (void)_setupImageProcessingView {
    // Set up ImageProcessingViewController and adding as child view controller
    self.impvc = [[ImageProcessingViewController alloc] initWithNibName:@"ImageProcessingViewController" bundle:nil];
    [self addChildViewController:_impvc];

    [self.view addSubview:_impvc.view];
}

- (void)_setupNavView {
    // Set up NavigationViewController and adding as child view controller
    _nvc = [[NavigationViewController alloc]initWithNibName:@"NavigationViewController" bundle: nil];
    
    [self addChildViewController:_nvc];
    [self.view addSubview:self.nvc.view];
}

- (void)_setupRevealMenu {
    // Creating button with profile picture
    [self _loadDataAndProfilePic];

    _showingProfilePic = YES;
    
    _revealButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [[_revealButton imageView] setContentMode:UIViewContentModeScaleAspectFill];
    [_revealButton setImage:[UIImage imageNamed:@"profile.jpg"] forState:UIControlStateNormal];
    _revealButton.frame = CGRectMake(PROFILE_PIC_ORIGIN, PROFILE_PIC_ORIGIN, PROFILE_PIC_SIZE, PROFILE_PIC_SIZE);
    _revealButton.clipsToBounds = YES;
    _revealButton.layer.cornerRadius = PROFILE_PIC_SIZE / 2.0;
    _revealButton.layer.borderColor = [UIColor whiteColor].CGColor;
    _revealButton.layer.borderWidth = 3.0f;
    _revealButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;

    // Places button below NavigationViewController
    [self.view insertSubview:_revealButton atIndex:[self.view.subviews indexOfObjectIdenticalTo:_impvc.view] + 2];

    SWRevealViewController *revealController = [self revealViewController];
    revealController.delegate = self;
    [self.view addGestureRecognizer:revealController.panGestureRecognizer];
    [_revealButton addTarget:self action:@selector(_revealMenu) forControlEvents:UIControlEventTouchUpInside];
}

- (void)_revealMenu{
    [[self revealViewController] revealToggle:nil];
    [self _changeRevealButtonPic];
}

- (void)_changeRevealButtonPic {
    if (self.showingProfilePic == YES) {
        [UIView animateWithDuration:0.4
                              delay:0.0
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^{_revealButton.alpha = 0.0;}
                         completion:nil];
        
        self.showingProfilePic = NO;
        [_revealButton setImage: [UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
        _revealButton.layer.borderColor = [UIColor clearColor].CGColor;
        
        [UIView animateWithDuration:0.4
                              delay:0.0
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^{_revealButton.alpha = 1.0;}
                         completion:nil];
    }
    else {
        [UIView animateWithDuration:0.4
                              delay:0.0
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^{_revealButton.alpha = 0.0;}
                         completion:nil];
        
        self.showingProfilePic = YES;
        
        if (!_profilePic) {
            [_revealButton setImage:[UIImage imageNamed:@"profile.jpg"] forState:UIControlStateNormal];
        } else {
            [_revealButton setImage:_profilePic forState:UIControlStateNormal];
        }
        _revealButton.layer.borderColor = [UIColor whiteColor].CGColor;
        
        [UIView animateWithDuration:0.4
                              delay:0.0
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^{_revealButton.alpha = 1.0;}
                         completion:nil];
    }
}

- (void)_setupSearchView {
    _svc = [[SearchViewController alloc] initWithNibName:@"SearchViewController" bundle:nil];
    [self addChildViewController:_svc];

    _svc.view.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
    [self.view addSubview:_svc.view];
}

- (void)_setupGestureRecognizers {
    UITapGestureRecognizer *navTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showSearch:)];
    navTapGesture.numberOfTapsRequired = 1;

    UISwipeGestureRecognizer *mainSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showSearch:)];
    mainSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionUp;

    [_nvc.navigationBar addGestureRecognizer:navTapGesture];
    [_nvc.view addGestureRecognizer:mainSwipeGestureRecognizer];
}

- (void)_setupFBTweaks {
    UIButton *tweaks = [UIButton buttonWithType:UIButtonTypeCustom];
    [tweaks setImage:[UIImage imageNamed:@"tweaks.jpg"] forState:UIControlStateNormal];
    tweaks.frame = CGRectMake(4 * PROFILE_PIC_ORIGIN, PROFILE_PIC_ORIGIN, PROFILE_PIC_SIZE, PROFILE_PIC_SIZE);
    tweaks.clipsToBounds = YES;
    tweaks.layer.cornerRadius = PROFILE_PIC_SIZE / 2.0;
    tweaks.layer.borderColor = [UIColor whiteColor].CGColor;
    tweaks.layer.borderWidth = 3.0f;

    [self.view insertSubview:tweaks atIndex:[self.view.subviews indexOfObjectIdenticalTo:_impvc.view] + 2];

    [tweaks addTarget:self action:@selector(_FBTweaksButtonTapped) forControlEvents:UIControlEventTouchUpInside];
}

- (void)_FBTweaksButtonTapped {
    FBTweakViewController *viewController = [[FBTweakViewController alloc] initWithStore:[FBTweakStore sharedInstance]];
    viewController.tweaksDelegate = self;
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)_setupTimeSpentBikingLabel {
    _timeSpentBikingLabel = [[UILabel alloc] init];
    _timeSpentBikingLabel.textColor = [UIColor whiteColor];
    _timeSpentBikingLabel.font = [UIFont boldSystemFontOfSize:25.0f];
    _timeSpentBikingLabel.text = @"00:00:00";
    
    [self.view insertSubview:_timeSpentBikingLabel atIndex:[self.view.subviews indexOfObjectIdenticalTo:_impvc.view] + 2];
    [_timeSpentBikingLabel setHidden:YES];
}

- (void)_setConstraintsProgramatically {
    float fromLeftEdge = self.view.bounds.size.width - PROFILE_PIC_ORIGIN - TIME_LABEL_WIDTH;
    float fromTopEdge = PROFILE_PIC_ORIGIN + PROFILE_PIC_SIZE / 2.0 - TIME_LABEL_HEIGHT / 2.0;
    
    _timeSpentBikingLabel.frame = CGRectMake(fromLeftEdge, fromTopEdge, TIME_LABEL_WIDTH, TIME_LABEL_HEIGHT);
}

- (void)tweakViewControllerPressedDone:(FBTweakViewController *)tweakViewController {
    [tweakViewController dismissViewControllerAnimated:YES completion:NULL];
}

- (void)showSearch:(NSObject *)sender {
    [UIView animateWithDuration:SLIDE_TIMING delay:0 usingSpringWithDamping:10 initialSpringVelocity:0 options:UIViewAnimationTransitionNone animations:^{
        [_nvc.navigationBar setHidden:YES];
        [_svc.navigationBar setHidden:NO];
        [_svc.map setHidden:NO];
        [_svc.view setHidden:NO];
        [_svc.view setAlpha:1.0];
        _svc.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);

        _nvc.navigationBar.frame = CGRectMake(0, 0, self.view.frame.size.width, NAVIGATION_BAR_HEIGHT);
    } completion:^(BOOL finished) {
        _impvc.hidden = YES;
        [self.view removeGestureRecognizer:[self revealViewController].panGestureRecognizer];
        
        if ([[self revealViewController] frontViewPosition] == FrontViewPositionRight) {
            [[self revealViewController] revealToggle:nil];
            [self _changeRevealButtonPic];
        }
    }];

}

- (void)dismissSearch:(NSObject *)sender {
    [UIView animateWithDuration:SLIDE_TIMING delay:0 usingSpringWithDamping:10 initialSpringVelocity:0 options:UIViewAnimationTransitionNone animations:^{
        _nvc.navigationBar.frame = CGRectMake(0, self.view.frame.size.height - NAVIGATION_BAR_HEIGHT, self.view.frame.size.width, NAVIGATION_BAR_HEIGHT);

        _svc.view.frame = CGRectMake(0, self.view.frame.size.height - NAVIGATION_BAR_HEIGHT, self.view.frame.size.width, self.view.frame.size.height);
        [_nvc.navigationBar setHidden:NO];
        [_svc.view setAlpha:0.0];
    } completion:^(BOOL finished) {
        _impvc.hidden = NO;
        [_svc.map setHidden:YES];
        [_svc.view setHidden:YES];
        [self.view addGestureRecognizer:[self revealViewController].panGestureRecognizer];
    }];
}


- (void)_loadDataAndProfilePic {
    // ...
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"id, name"}];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            // result is a dictionary with the user's Facebook data
            NSDictionary *userData = (NSDictionary *)result;

            NSString *facebookID = userData[@"id"];
            //NSString *name = userData[@"name"];

            NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=normal&return_ssl_resources=1", facebookID]];
            
            self.profilePicURL = pictureURL;

            [self setProfilePic];
        
        }
    }];
}

- (void)setProfilePic{

    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:self.profilePicURL];

    // Run network request asynchronously
    [NSURLConnection sendAsynchronousRequest:urlRequest
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:
     ^(NSURLResponse *response, NSData *data, NSError *connectionError) {
         if (connectionError == nil && data != nil) {
             // Set the image in the imageView
             self.profilePic = [UIImage imageWithData:data];
    
             _revealButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
             [_revealButton setImage:self.profilePic forState:UIControlStateNormal];
         }
     }];
}



- (void)_showUpdatedTime {
    int totalSeconds = (int)[[SessionManager sharedInstance] secondsSpentBiking];

    int conversion = 60;
    int sec = totalSeconds % conversion;
    int min = (totalSeconds - sec) / conversion;
    int hours = min / conversion;
    min = min % conversion;

    _timeSpentBikingLabel.text = [NSString stringWithFormat:@"%.02u:%.02u:%.02u", hours, min, sec];

    [self performSelector:@selector(_showUpdatedTime) withObject:self afterDelay:0.5];
}

- (void)_sessionSaved {
    [CSNotificationView showInViewController:self
                                       style:CSNotificationViewStyleSuccess
                                     message:@"Trip saved!"];
}

- (void)_sessionStarted {
    //[self.view insertSubview:_timeSpentBikingLabel atIndex:[self.view.subviews indexOfObjectIdenticalTo:_impvc.view] + 2];
    [_timeSpentBikingLabel setHidden:NO];
}

- (void)_sessionStopped {
    [_timeSpentBikingLabel setHidden:YES];
}

- (void)_sessionDiscarded {
    [CSNotificationView showInViewController:self
                                       style:CSNotificationViewStyleError
                                     message:@"Trip is too short and will not be saved."];
}

# pragma mark - SWRevealController delegate method

- (void)revealController:(SWRevealViewController *)revealController panGestureEndedToLocation:(CGFloat)location progress:(CGFloat)progress overProgress:(CGFloat)overProgress {
    [self _revealMenu];
}

@end
