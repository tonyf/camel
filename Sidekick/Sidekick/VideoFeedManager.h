//
//  VideoFeedManager.h
//  Sidekick
//
//  Created by Kathleen Feng on 7/12/15.
//  Copyright (c) 2015 thesquad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <opencv2/videoio/cap_ios.h>

@protocol VideoFeedManagerDelegate <NSObject>

- (void)processImage:(cv::Mat &)image;

@end

@interface VideoFeedManager : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate>

@property (assign, nonatomic) id delegate;

@property (strong, nonatomic) AVCaptureSession *session;
@property (strong, nonatomic) AVCaptureDevice *device;
@property (strong, nonatomic) AVCaptureDeviceInput *input;
@property (strong, nonatomic) AVCaptureVideoDataOutput *output;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;

- (void)switchCamera;

@end
