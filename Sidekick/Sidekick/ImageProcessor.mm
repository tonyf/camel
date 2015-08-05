//
//  ImageProcessor.m
//  Sidekick
//
//  Created by Kathleen Feng on 7/12/15.
//  Copyright (c) 2015 thesquad. All rights reserved.
//

#import "ImageProcessor.h"

#import <Tweaks/FBTweak.h>
#import <Tweaks/FBTweakInline.h>

// Options for cv::CascadeClassifier::detectMultiScale
// CV_HAAR_FIND_BIGGEST_OBJECT finds the biggest match
// CV_HAAR_DO_ROUGH_SEARCH finds all matches
const int kDetectOptions = CV_HAAR_FIND_BIGGEST_OBJECT | CV_HAAR_DO_ROUGH_SEARCH;

@interface ImageProcessor ()

@property (nonatomic, assign) int frameThreshold;
@property (nonatomic, assign) int frameCount;
@property (nonatomic, strong) NSString *carCascadeFilename;
@property (nonatomic, assign) int fps;
@property (nonatomic, assign) int framesReceived;

@end

@implementation ImageProcessor

- (instancetype)init {
    self = [super init];
    if (self) {
        // Loading file into cascade
        FBTweakBind(self, car, @"Image Processing", @"Detection", @"Car Cascade", YES);
        if (_car) {
            _carCascadeFilename = @"cascaderev";
        } else {
            _carCascadeFilename = @"haarcascade_frontalface_alt2";
        }
        
        NSString *filePath = [[NSBundle mainBundle] pathForResource:_carCascadeFilename ofType:@"xml"];
        _cascade.load([filePath UTF8String]);
        
        _frontCamera = YES; // initializing with front camera;
        
        _frameCount = 0;
        FBTweakBind(self, frameThreshold, @"Image Processing", @"Audio Alerts", @"Frame Threshold", 3, 0, 30);
        
        _framesReceived = 0;
        FBTweakBind(self, fps, @"Image Processing", @"Video Feed", @"Every ?? Frames Processed", 2, 0, 10);
    }
    return self;
}

- (void)processImage:(cv::Mat &)image
         orientation:(UIDeviceOrientation)orientation {
    
    _framesReceived++;
    
    if (_framesReceived >= _fps - 1) {
        _framesReceived = 0;
        if (_frontCamera && orientation == UIDeviceOrientationLandscapeLeft) {
            cv::flip(image, image, 0);
        } else if (_frontCamera && orientation == UIDeviceOrientationLandscapeRight) {
            cv::flip(image, image, 1);
        } else if (!_frontCamera && orientation == UIDeviceOrientationLandscapeRight) {
            cv::flip(image, image, -1);
        }
        
        cv::Mat grayscale;
        
        cv::cvtColor(image, grayscale, CV_BGRA2GRAY);
        cv::equalizeHist(grayscale, grayscale);
        
        std::vector<cv::Rect> cars;
        
        _cascade.detectMultiScale(grayscale, cars, 1.1, 6, kDetectOptions, cv::Size(30, 30));
        
        if (cars.size() > 0) {
            _frameCount++;
            
            // Alerts user with sound if car has been detected for at least frameThreshold frames
            if (_frameCount == _frameThreshold) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    if ([_delegate respondsToSelector:@selector(alertWithSound)]) {
                        [_delegate alertWithSound];
                    }
                });
            }
        } else {
            _frameCount = 0;
        }
        
        // Drawing faces on the main queue
        dispatch_sync(dispatch_get_main_queue(), ^{
            if ([_delegate respondsToSelector:@selector(drawDetectedCars:)]) {
                [_delegate drawDetectedCars:cars];
            }
        });
    }
}

@end
