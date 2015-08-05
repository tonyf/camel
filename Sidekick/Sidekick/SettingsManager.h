//
//  SettingsManager.h
//  Sidekick
//
//  Created by Kathleen Feng on 7/23/15.
//  Copyright (c) 2015 thesquad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IASKAppSettingsViewController.h"

@interface SettingsManager : NSObject <IASKSettingsDelegate>

@property (nonatomic, strong) IASKAppSettingsViewController *appSettingsViewController;

@end
