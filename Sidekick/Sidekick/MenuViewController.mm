//
//  MenuViewController.m
//  Sidekick
//
//  Created by Kathleen Feng on 7/17/15.
//  Copyright (c) 2015 thesquad. All rights reserved.
//

#import "MenuViewController.h"
#import "SWRevealViewController.h"
#import "SessionManager.h"
#import "TripLogViewController.h"
#import "MainViewController.h"

@interface MenuViewController ()

@property (strong, nonatomic) UIButton *tripLog;
@property (strong, nonatomic) UIButton *startSession;
@property (strong, nonatomic) UIButton *pauseSession;
@property (strong, nonatomic) UIButton *stopSession;
@property (strong, nonatomic) UIButton *settings;
@property (strong, nonatomic) SessionManager *sessionManager;
@property (assign, nonatomic) BOOL pauseButton;

- (void)_tripLogButtonDidPress;
- (void)_startButtonDidPress;
- (void)_pauseButtonDidPress;
- (void)_stopButtonDidPress;
- (void)_settingsButtonDidPress;
- (void)_showPlayButton;
- (void)_showPauseButton;
- (void)_setupSettingsView;
- (void)_hideMenuViewController;

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _sessionManager = [SessionManager sharedInstance];
    
    UIColor *background = [[UIColor alloc] initWithRed:45.0 / 255.0 green:45.0 / 255.0 blue:45.0 / 255.0 alpha:1.0];
    
    _tripLog = [UIButton buttonWithType:UIButtonTypeCustom];
    _tripLog.backgroundColor = background;
    [_tripLog setImage:[UIImage imageNamed:@"triplog.png"] forState:UIControlStateNormal];
    [self.view addSubview:_tripLog];
    
    _startSession = [UIButton buttonWithType:UIButtonTypeCustom];
    _startSession.backgroundColor = background;
    [_startSession setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
    [self.view addSubview:_startSession];
    
    _pauseSession = [UIButton buttonWithType:UIButtonTypeCustom];
    _pauseSession.backgroundColor = background;
    [_pauseSession setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
    
    _stopSession = [UIButton buttonWithType:UIButtonTypeCustom];
    _stopSession.backgroundColor = background;
    [_stopSession setImage:[UIImage imageNamed:@"stop.png"] forState:UIControlStateNormal];
    [self.view addSubview:_stopSession];
    
    _settings = [UIButton buttonWithType:UIButtonTypeCustom];
    _settings.backgroundColor = background;
    [_settings setImage:[UIImage imageNamed:@"settings.png"] forState:UIControlStateNormal];
    [self.view addSubview:_settings];
    
    [_startSession addTarget:self action:@selector(_startButtonDidPress) forControlEvents:UIControlEventTouchUpInside];
    [_pauseSession addTarget:self action:@selector(_pauseButtonDidPress) forControlEvents:UIControlEventTouchUpInside];
    [_tripLog addTarget:self action:@selector(_tripLogButtonDidPress) forControlEvents:UIControlEventTouchUpInside];
    [_stopSession addTarget:self action:@selector(_stopButtonDidPress) forControlEvents:UIControlEventTouchUpInside];
    [_settings addTarget:self action:@selector(_settingsButtonDidPress) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews {
    float height = self.view.bounds.size.height / 4.0;
    float width = self.revealViewController.rearViewRevealWidth;
    
    int tbmargin = 20;
    float y = height - 2 * tbmargin;
    
    float scale = _tripLog.imageView.image.size.width / _tripLog.imageView.image.size.height;
    _tripLog.frame = CGRectMake(0, 0, width, height);
    _tripLog.imageEdgeInsets = UIEdgeInsetsMake(tbmargin, (width - y * scale) / 2, tbmargin, (width - y * scale) / 2);
    
    scale = _startSession.imageView.image.size.width / _startSession.imageView.image.size.height;
    _startSession.frame = CGRectMake(0, height, width, height);
    _startSession.imageEdgeInsets = UIEdgeInsetsMake(tbmargin, (width - y * scale) / 2, tbmargin, (width - y * scale) / 2);
    
    scale = _pauseSession.imageView.image.size.width / _startSession.imageView.image.size.height;
    _pauseSession.frame = CGRectMake(0, height, width, height);
    _pauseSession.imageEdgeInsets = UIEdgeInsetsMake(tbmargin, (width - y * scale) / 2, tbmargin, (width - y * scale) / 2);
    
    scale = _stopSession.imageView.image.size.width / _stopSession.imageView.image.size.height;
    _stopSession.frame = CGRectMake(0, 2 * height, width, height);
    _stopSession.imageEdgeInsets = UIEdgeInsetsMake(tbmargin, (width - y * scale) / 2, tbmargin, (width - y * scale) / 2);
    
    scale = _settings.imageView.image.size.width / _settings.imageView.image.size.height;
    _settings.frame = CGRectMake(0, 3 * height, width, height);
    _settings.imageEdgeInsets = UIEdgeInsetsMake(tbmargin, (width - y * scale) / 2, tbmargin, (width - y * scale) / 2);
    
    // Set up only bottom border on each button
    UIColor *border = [[UIColor alloc] initWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
    
    UIView *lineView1 = [[UIView alloc] initWithFrame:CGRectMake(0, height - 1, width, 1)];
    lineView1.backgroundColor = border;
    [_tripLog addSubview:lineView1];
    
    UIView *lineView2 = [[UIView alloc] initWithFrame:CGRectMake(0, height - 1, width, 1)];
    lineView2.backgroundColor = border;
    [_startSession addSubview:lineView2];
    
    UIView *lineView3 = [[UIView alloc] initWithFrame:CGRectMake(0, height - 1, width, 1)];
    lineView3.backgroundColor = border;
    [_pauseSession addSubview:lineView3];
    
    UIView *lineView4 = [[UIView alloc] initWithFrame:CGRectMake(0, height - 1, width, 1)];
    lineView4.backgroundColor = border;
    [_stopSession addSubview:lineView4];
}

- (void)_showPlayButton {
    [_pauseSession removeFromSuperview];
    
    [self.view addSubview:_startSession];
}

- (void)_showPauseButton {
    [_startSession removeFromSuperview];
    
    [self.view addSubview:_pauseSession];
}

- (void)_tripLogButtonDidPress {
    TripLogViewController *tvc = [[TripLogViewController alloc] initWithNibName:@"TripLogViewController" bundle:nil];
    tvc.menu = self;
    [self presentViewController:tvc animated:YES completion:nil];
}

- (void)_startButtonDidPress {
    [[SessionManager sharedInstance] sessionStarted];
    
    _pauseButton = YES;
    
    [self _hideMenuViewController];
    
    [self _showPauseButton];
}

- (void)_pauseButtonDidPress {
    [[SessionManager sharedInstance] sessionPaused];
    
    _pauseButton = NO;
    
    [self _hideMenuViewController];
    
    [self _showPlayButton];
}

- (void)_stopButtonDidPress {
    [[SessionManager sharedInstance] sessionStopped];
    
    [self _showPlayButton];
}

- (void)_settingsButtonDidPress {
    if (!_settingsManager) {
        [self _setupSettingsView];
    }
    
    UINavigationController *settings = [[UINavigationController alloc] initWithRootViewController:_settingsManager.appSettingsViewController];
    [self presentViewController:settings animated:YES completion:nil];
}

- (void)_setupSettingsView {
    _settingsManager = [[SettingsManager alloc] init];
}

- (void)_hideMenuViewController {
    [[self revealViewController] revealToggle:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MenuViewControllerHidden" object:nil];
}

@end
