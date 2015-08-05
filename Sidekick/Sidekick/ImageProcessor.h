//
//  ImageProcessor.h
//  Sidekick
//
//  Created by Kathleen Feng on 7/12/15.
//  Copyright (c) 2015 thesquad. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <opencv2/opencv.hpp>
#import <opencv2/videoio/cap_ios.h>

@protocol ImageProcessorDelegate <NSObject>

- (void)drawDetectedCars:(const std::vector<cv::Rect> &)cars;
- (void)alertWithSound;

@end

@interface ImageProcessor : NSObject

@property (nonatomic, strong) id delegate;
@property (nonatomic, assign) cv::CascadeClassifier cascade;
@property (nonatomic, assign) BOOL frontCamera;
@property (nonatomic, assign) BOOL car;

- (void)processImage:(cv::Mat &)image
         orientation:(UIDeviceOrientation)orientation;

@end
