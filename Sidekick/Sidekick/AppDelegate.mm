// Copyright 2004-present Facebook. All Rights Reserved.

#import <Tweaks/FBTweak.h>
#import <Tweaks/FBTweakShakeWindow.h>
#import <Tweaks/FBTweakInline.h>
#import <Tweaks/FBTweakViewController.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "LoginViewController.h"

#import "AppDelegate.h"
#import <Wit/Wit.h>
#import "MainViewController.h"
#import "SWRevealViewController.h"
#import "MenuViewController.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>

@interface AppDelegate () <FBTweakViewControllerDelegate, SWRevealViewControllerDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    [UIApplication sharedApplication].idleTimerDisabled = YES;

    [Parse setApplicationId:@"d38DQb5TqEJ7hn6ytwomERF9JsaZgDNnrdnOMJIF" clientKey:@"nyjtllt0oS6uwJ2yOLSTHjHdYM3K0ut9ebZitkyB"];
    [PFFacebookUtils initializeFacebookWithApplicationLaunchOptions:launchOptions];

    // Wit setup
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];

    [Wit sharedInstance].accessToken = @"LJ52IPE6X6EV63YP43MNKXX4QPUMCB4A";
    // enabling detectSpeechStop will automatically stop listening the microphone when the user stop talking
    [Wit sharedInstance].detectSpeechStop = WITVadConfigDetectSpeechStop;

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    self.window.backgroundColor = [UIColor whiteColor];
    
    if ([PFUser currentUser]) {
        MainViewController *mvc = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
        MenuViewController *menu = [[MenuViewController alloc] initWithNibName:@"MenuViewController" bundle:nil];
        
        SWRevealViewController *revealController = [[SWRevealViewController alloc] initWithRearViewController:menu frontViewController:mvc];
        
        revealController.rearViewRevealWidth = 110;
        revealController.rearViewRevealOverdraw = 0;
        revealController.bounceBackOnOverdraw = NO;
        revealController.stableDragOnOverdraw = YES;
        
        self.window.rootViewController = revealController;
    } else {
        LoginViewController *lvc = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        self.window.rootViewController = lvc;
    }
    
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *alertDefault = [standardUserDefaults objectForKey:@"alertSounds"];
    if (!alertDefault) {
        [self registerDefaultsFromSettingsBundle];
    }

    [self.window makeKeyAndVisible];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBSDKAppEvents activateApp];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)tweakViewControllerPressedDone:(FBTweakViewController *)tweakViewController {
    [tweakViewController dismissViewControllerAnimated:YES completion:NULL];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];

}

- (void)registerDefaultsFromSettingsBundle {
    // this function writes default settings as settings
    NSString *settingsBundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
    if(!settingsBundle) {
        NSLog(@"Could not find Settings.bundle");
        return;
    }
    
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[settingsBundle stringByAppendingPathComponent:@"Root.plist"]];
    NSArray *preferences = [settings objectForKey:@"PreferenceSpecifiers"];
    
    NSMutableDictionary *defaultsToRegister = [[NSMutableDictionary alloc] initWithCapacity:[preferences count]];
    for(NSDictionary *prefSpecification in preferences) {
        NSString *key = [prefSpecification objectForKey:@"Key"];
        if(key) {
            [defaultsToRegister setObject:[prefSpecification objectForKey:@"DefaultValue"] forKey:key];
        }
    }
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultsToRegister];
    
}

@end
