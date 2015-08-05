//
//  ImageProcessingViewController.m
//  Sidekick
//
//  Created by Kathleen Feng on 7/13/15.
//  Copyright (c) 2015 thesquad. All rights reserved.
//

#import "ImageProcessingViewController.h"
#import "SWRevealViewController.h"
#import "AlertPlayer.h"

@interface ImageProcessingViewController ()

@property (nonatomic, assign) UIDeviceOrientation orientation;
@property (nonatomic, strong) AlertPlayer *alertPlayer;

@end

@implementation ImageProcessingViewController 

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _video = [[VideoFeedManager alloc] init];
        _video.delegate = self;
        
        _processor = [[ImageProcessor alloc] init];
        _processor.delegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Shows video feed
    _video.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_video.session];
    _video.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _video.previewLayer.name = @"VideoLayer";
    [self.view.layer insertSublayer:_video.previewLayer atIndex:0];
    
    [_video.session startRunning];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _video.previewLayer.frame = self.view.bounds;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    _hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _hidden = NO;
    
    // Sets orientation of preview layer to the orientation of the device
    AVCaptureConnection *connection = [_video.previewLayer connection];
    _orientation = [[UIDevice currentDevice] orientation];
    if (_orientation == UIDeviceOrientationLandscapeRight) {
        if ([connection isVideoOrientationSupported]) {
            [connection setVideoOrientation:AVCaptureVideoOrientationLandscapeLeft];
        }
    } else {
        if ([connection isVideoOrientationSupported]) {
            [connection setVideoOrientation:AVCaptureVideoOrientationLandscapeRight];
        }
    }
    
    // Enables video stabilization if supported
    if (connection.supportsVideoStabilization) {
        connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)processImage:(cv::Mat &)image {
    
    if (!_hidden) {
    
        float scale = [UIScreen mainScreen].scale;
        
        cv::resize(image, image, cv::Size(self.view.frame.size.width, self.view.frame.size.height), 1.0 / scale, 1.0 / scale, CV_INTER_LINEAR);
        
        [_processor processImage:image
                     orientation:_orientation];
    }
}

- (void)drawDetectedCars:(const std::vector<cv::Rect> &)cars {
    // Draw boxes around all the detected cars
    
    NSArray *sublayers = [NSArray arrayWithArray:[self.view.layer sublayers]];
    int sublayersCount = (int)[sublayers count];
    int currentSublayer = 0;
    
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    
    // hide all the car layers
    for (CALayer *layer in sublayers) {
        NSString *layerName = [layer name];
        if ([layerName isEqualToString:@"CarLayer"])
            [layer setHidden:YES];
    }
    
    for (int i = 0; i < cars.size(); i++) {
        CGRect drawRect;
        drawRect.origin.x = cars[i].x;
        drawRect.origin.y = cars[i].y;
        drawRect.size.width = cars[i].width;
        drawRect.size.height = cars[i].height;
        
        CALayer *featureLayer = nil;
        
        while (!featureLayer && (currentSublayer < sublayersCount)) {
            CALayer *currentLayer = [sublayers objectAtIndex:currentSublayer++];
            if ([[currentLayer name] isEqualToString:@"CarLayer"]) {
                featureLayer = currentLayer;
                [currentLayer setHidden:NO];
            }
        }
        
        if (!featureLayer) {
            // Create a new feature marker layer
            featureLayer.frame = _video.previewLayer.frame;
            featureLayer = [[CALayer alloc] init];
            featureLayer.name = @"CarLayer";
            featureLayer.borderColor = [[UIColor redColor] CGColor];
            featureLayer.borderWidth = 5.0f;
            [self.view.layer insertSublayer:featureLayer atIndex:1];
        }
        
        featureLayer.frame = drawRect;
    }
    
    [CATransaction commit];
}

- (IBAction)switchCamera:(id)sender {
    [_video switchCamera];
    
    if (_processor.frontCamera) {
        _processor.frontCamera = NO;
    } else {
        _processor.frontCamera = YES;
    }
}

- (void)alertWithSound {
    [[AlertPlayer sharedInstance] play];
}

- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    _orientation = [[UIDevice currentDevice] orientation];
    
    AVCaptureConnection *connection = [_video.previewLayer connection];
    if (_orientation == UIDeviceOrientationLandscapeLeft) {
        if ([connection isVideoOrientationSupported]) {
            [connection setVideoOrientation:AVCaptureVideoOrientationLandscapeRight];
        }
    } else {
        if ([connection isVideoOrientationSupported]) {
            [connection setVideoOrientation:AVCaptureVideoOrientationLandscapeLeft];
        }
    }
}

@end
