//
//  VideoFeedManager.m
//  Sidekick
//
//  Created by Kathleen Feng on 7/12/15.
//  Copyright (c) 2015 thesquad. All rights reserved.
//

#import "VideoFeedManager.h"
#import <Tweaks/FBTweak.h>
#import <Tweaks/FBTweakInline.h>

@interface VideoFeedManager ()

@end

@implementation VideoFeedManager

- (instancetype)init {
    self = [super init];
    if (self) {
        // Creating AVCaptureSession
        _session = [[AVCaptureSession alloc] init];
        _session.sessionPreset = AVCaptureSessionPresetPhoto;
        
        // Get input from front video camera
        NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        _device = nil;
        for (AVCaptureDevice *captureDevice in videoDevices) {
            if (captureDevice.position == AVCaptureDevicePositionFront) {
                _device = captureDevice;
                break;
            }
        }
        // If no front camera found, set with default camera
        if (!_device) {
            _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        }
        
        // Set input device for the AVCaptureSession
        NSError *error = nil;
        _input = [AVCaptureDeviceInput deviceInputWithDevice:_device error:&error];
        if (!_input) {
            NSLog(@"No input device with error: %@", error);
        }
        
        if ([_session canAddInput:_input]) {
            [_session addInput:_input];
        }
        
        // Video output
        _output = [[AVCaptureVideoDataOutput alloc] init];
        _output.videoSettings = [NSDictionary dictionaryWithObject:[NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA]
                                                            forKey:(id)kCVPixelBufferPixelFormatTypeKey];
        
        // Uncomment if data output queue is blocked
        [_output setAlwaysDiscardsLateVideoFrames:YES];
        
        // Queue on which callbacks should be invoked
        dispatch_queue_t queue = dispatch_queue_create("VideoQueue", DISPATCH_QUEUE_SERIAL);
        [_output setSampleBufferDelegate:self queue:queue];
        
        if ([_session canAddOutput:_output]) {
            [_session addOutput:_output];
        }
    }
    return self;
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection {
    
    // convert from Core Media to Core Video
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    void* bufferAddress;
    size_t width;
    size_t height;
    size_t bytesPerRow;
    int format_opencv;
    
    OSType format = CVPixelBufferGetPixelFormatType(imageBuffer);
    // Only format taken by iPhone 6
    if (format == kCVPixelFormatType_32BGRA){
        
        format_opencv = CV_8UC4;
        
        bufferAddress = CVPixelBufferGetBaseAddress(imageBuffer);
        width = CVPixelBufferGetWidth(imageBuffer);
        height = CVPixelBufferGetHeight(imageBuffer);
        bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
        
    }
    
    // delegate image processing to the delegate
    cv::Mat image((int)height, (int)width, format_opencv, bufferAddress, bytesPerRow);
    
    if ([_delegate respondsToSelector:@selector(processImage:)]) {
        [_delegate processImage:image];
    }
    
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
}

- (void)switchCamera {
    [_session beginConfiguration];
    
    [_session removeInput:_input];
    
    if (_device.position == AVCaptureDevicePositionFront) {
        _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        NSError *error = nil;
        _input = [AVCaptureDeviceInput deviceInputWithDevice:_device error:&error];
        if (!_input) {
            NSLog(@"No input device with error: %@", error);
        }
        
        if ([_session canAddInput:_input]) {
            [_session addInput:_input];
        }
    } else {
        NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        
        for (AVCaptureDevice *captureDevice in videoDevices) {
            if (captureDevice.position == AVCaptureDevicePositionFront) {
                _device = captureDevice;
                break;
            }
        }
        // If no front camera found, set with default camera
        if (!_device) {
            _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        }
        
        NSError *error = nil;
        _input = [AVCaptureDeviceInput deviceInputWithDevice:_device error:&error];
        if (!_input) {
            NSLog(@"No input device with error: %@", error);
        }
        
        if ([_session canAddInput:_input]) {
            [_session addInput:_input];
        }
    }
    
    [_session commitConfiguration];
}

@end
