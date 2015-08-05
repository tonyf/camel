//
//  LoginViewController.h
//  Sidekick
//
//  Created by Bernard Snowden on 7/20/15.
//  Copyright (c) 2015 thesquad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBSDKCoreKit/FBSDKCoreKit.h"
#import "FBSDKLoginKit/FBSDKLoginKit.h"
#import "SWRevealViewController.h"
#import "MainViewController.h"

@interface LoginViewController : UIViewController

@property (nonatomic, strong) MainViewController *mvc;
@property (nonatomic, weak) id <SWRevealViewControllerDelegate> swcDelegate;

- (void)_checkInvalidatedSession;

@end
