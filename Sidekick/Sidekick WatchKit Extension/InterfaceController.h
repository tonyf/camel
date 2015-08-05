//
//  InterfaceController.h
//  Sidekick WatchKit Extension
//
//  Created by Tony Francis on 7/22/15.
//  Copyright (c) 2015 thesquad. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface InterfaceController : WKInterfaceController
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *turnInstruction;
@property (weak, nonatomic) IBOutlet WKInterfaceMap *map;

@end
