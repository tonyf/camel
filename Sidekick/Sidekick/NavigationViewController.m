// Copyright 2004-present Facebook. All Rights Reserved.

#define SLIDE_TIMING .85
#define PANEL_WIDTH 667

#import "NavigationViewController.h"
#import "VoiceNavigationManager.h"
#import "SearchViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "SearchResult.h"

@interface NavigationViewController ()
@property (nonatomic, strong) MKPointAnnotation *pin;
@property (nonatomic, strong) SearchResult *pinSearchResult;
@property (nonatomic, assign) BOOL needsToBeSpoken;
@property (nonatomic, assign) BOOL isInNavigation;
@end


@implementation NavigationViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [VoiceNavigationManager sharedInstance].delegate = self;
        _isInNavigation = NO;
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!_isInNavigation) {
        [self showCurrentLocationString];
    }
}

- (void)showCurrentLocationString {
    [[VoiceNavigationManager sharedInstance] currentLocationAsString:^(BOOL success, NSString *location) {
        if (success) {
            _instructionsLabel.text = [NSString stringWithFormat:@"Around %@", location];
        }
    }];
}

- (void)navigateForCurrentPin {
    [[VoiceNavigationManager sharedInstance] getDirectionsToLocation:_pinSearchResult.location];
}

- (IBAction)searchButtonPressed:(UIButton *)sender {
    SEL selector = NSSelectorFromString(@"showSearch:");
    [self.parentViewController performSelectorInBackground:selector withObject:self];
}

// MARK - Navigation

- (void)startNavigationWithInstruction:(NSString *)instruction {
    _instructionsLabel.text = instruction;
    _needsToBeSpoken = NO;
    _isInNavigation = YES;
}

- (void)endNavigation {
    _instructionsLabel.text = @"";
    _distanceLabel.text = @"";
    [self showCurrentLocationString];
    _needsToBeSpoken = NO;
    _isInNavigation = NO;
}

- (void)presentNavigationDirection:(ProcessedDirection
                                    *)direction {
    _instructionsLabel.text = direction.instruction;
    _needsToBeSpoken = YES;
}

- (void)presentNextTurnDistance:(CLLocationDistance)distance {
    MKDistanceFormatter *formatter = [[MKDistanceFormatter alloc] init];
    _distanceLabel.text = [formatter stringFromDistance:distance];
    if (distance < 400 && _needsToBeSpoken) {
        NSString *spokenInstruction = [NSString stringWithFormat:@"In %@, %@.", _distanceLabel.text, _instructionsLabel.text];
        AVSpeechSynthesizer *synthesizer = [[AVSpeechSynthesizer alloc]init];
        AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:spokenInstruction];
        [utterance setRate:0.25f];
        [synthesizer speakUtterance:utterance];
        _needsToBeSpoken = NO;
    }
}


@end
