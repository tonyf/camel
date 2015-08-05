//
//  SettingsManager.m
//  Sidekick
//
//  Created by Kathleen Feng on 7/23/15.
//  Copyright (c) 2015 thesquad. All rights reserved.
//

#import <Parse/Parse.h>
#import "SettingsManager.h"
#import "IASKSettingsReader.h"
#import "LoginViewController.h"
#import "AlertPlayer.h"

@interface SettingsManager ()

@property (nonatomic, strong) AlertPlayer *alertPlayer;

@end

@implementation SettingsManager

- (instancetype)init {
    self = [super init];
    if (self) {
        _appSettingsViewController = [[IASKAppSettingsViewController alloc] init];
        _appSettingsViewController.delegate = self;
        BOOL enabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"AutoConnect"];
        _appSettingsViewController.hiddenKeys = enabled ? nil : [NSSet setWithObjects:@"AutoConnectLong", @"AutoConnectPassword", nil];
        
        _appSettingsViewController.showDoneButton = YES;
        [_appSettingsViewController setShowCreditsFooter:NO];
        
    }
    return self;
}

- (IASKAppSettingsViewController *)appSettingsViewController {
    if (!_appSettingsViewController) {
        _appSettingsViewController = [[IASKAppSettingsViewController alloc] init];
        _appSettingsViewController.delegate = self;
        BOOL enabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"AutoConnect"];
        _appSettingsViewController.hiddenKeys = enabled ? nil : [NSSet setWithObjects:@"AutoConnectLong", @"AutoConnectPassword", nil];
    }
    return _appSettingsViewController;
}

- (void)settingsViewControllerDidEnd:(IASKAppSettingsViewController *)sender {
    [[AlertPlayer sharedInstance] changeAlert];
    
    [_appSettingsViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)settingsViewController:(IASKAppSettingsViewController *)sender buttonTappedForSpecifier:(IASKSpecifier *)specifier {
    if ([specifier.key isEqualToString:@"Logout"]) {
        [PFUser logOut];
        
        LoginViewController *lvc = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.appSettingsViewController presentViewController:lvc animated:YES completion:nil];
    }
}

@end
