//
//  ImageProcessingViewController.h
//  Sidekick
//
//  Created by Kathleen Feng on 7/13/15.
//  Copyright (c) 2015 thesquad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "VideoFeedManager.h"
#import "ImageProcessor.h"

@interface ImageProcessingViewController : UIViewController <VideoFeedManagerDelegate, ImageProcessorDelegate>

@property (nonatomic, strong) VideoFeedManager *video;
@property (nonatomic, strong) ImageProcessor *processor;
@property (nonatomic, assign) BOOL hidden;

@end
