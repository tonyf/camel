//
//  LoginViewController.m
//  Sidekick
//
//  Created by Bernard Snowden on 7/20/15.
//  Copyright (c) 2015 thesquad. All rights reserved.
//

#import "LoginViewController.h"
#import <Parse/Parse.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import "MenuViewController.h"
#import "SWRevealViewController.h"


@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)checkLoginSuccess{
    if ([PFUser currentUser] || [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        
        MainViewController *mvc = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
        MenuViewController *menu = [[MenuViewController alloc] initWithNibName:@"MenuViewController" bundle:nil];
        
        SWRevealViewController *revealController = [[SWRevealViewController alloc] initWithRearViewController:menu frontViewController:mvc];
        
        revealController.rearViewRevealWidth = 110;
        revealController.rearViewRevealOverdraw = 0;
        revealController.bounceBackOnOverdraw = NO;
        revealController.stableDragOnOverdraw = YES;
        
        [self presentViewController:revealController animated:YES completion:nil];
        
    }
}


- (void)_checkInvalidatedSession{
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"id, name"}];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            // handle successful response
        } else if ([[error userInfo][@"error"][@"type"] isEqualToString: @"OAuthException"]) { // Since the request failed, we can check if it was due to an invalid session
            NSLog(@"The facebook session was invalidated");
            [PFFacebookUtils unlinkUserInBackground:[PFUser currentUser]];
            
        } else {
            NSLog(@"Some other error: %@", error);
        }
    }];
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)loginButtonPressed:(id)sender {
    
    NSArray *permissionsArray = @[ @"user_birthday"];
    
    // Login PFUser using Facebook
    NSLog(@"Currently in loginButtonPressed:");
   
    [PFFacebookUtils logInInBackgroundWithReadPermissions:permissionsArray block:^(PFUser *user, NSError *error){
        if(!user){
            NSLog(@"Uh oh. The user cancelled the Facebook Login.");
        }
        else if(user.isNew){
            NSLog(@"The user is new and has logged in to Facebook");
            [self checkLoginSuccess];
        }
        else{
            NSLog(@"The user has successfully logged in to Facebook");
            
            [self checkLoginSuccess];
        }
    }];
    
}

@end
