//
//  FBTripShareManager.m
//  Sidekick
//
//  Created by Bernard Snowden on 7/23/15.
//  Copyright (c) 2015 thesquad. All rights reserved.
//

#import "FBTripShareManager.h"
#import <FBSDKShareKit/FBSDKShareKit.h>
#import "FBSDKGraphRequest.h"
#import "Trip.h"


@interface FBTripShareManager ()

@property (nonatomic, weak) UIViewController *moveFromVC;

@end

@implementation FBTripShareManager


- (void)shareTrip:(Trip *)trip AndMapImageToTimeline:(UIImage *)mapImage fromVC:(UIViewController *)mvc{
    
    //Create a FBPhoto Model to share
    FBSDKSharePhoto *sharePhoto = [[FBSDKSharePhoto alloc] init];
    sharePhoto.image = mapImage;
    sharePhoto.userGenerated = YES;
    
    FBSDKSharePhotoContent *content = [[FBSDKSharePhotoContent alloc] init];
    content.photos = @[sharePhoto];
    
    NSNumber *correctDistance = [[NSNumber alloc] initWithFloat:trip.distance * 0.000621];
    NSString *distanceInMiles = [NSString stringWithFormat:@"%@",correctDistance];
    NSString *seconds = [NSString stringWithFormat:@"%f",trip.secondsSpentBiking];
    // Create an object
    NSDictionary *properties = @{
                                 @"og:type": @"fitness.course",
                                 @"og:title": @"Camel",
                                 @"fitness:distance:value": distanceInMiles,
                                 @"fitness:distance:units":@"mi",
                                 @"fitness:duration:value":seconds,
                                 @"fitness:duration:units":@"s"
                                 };
    FBSDKShareOpenGraphObject *object = [FBSDKShareOpenGraphObject objectWithProperties:properties];
    
    FBSDKShareOpenGraphAction *action = [[FBSDKShareOpenGraphAction alloc] init];
    action.actionType = @"fitness.bikes";
    [action setObject:object forKey:@"fitness:course"];
    
    // Add the photo to the action. Actions
    // can take an array of images.
    [action setArray:@[sharePhoto] forKey:@"image"];
    
    // Create the content
    FBSDKShareOpenGraphContent *dynamicContent = [[FBSDKShareOpenGraphContent alloc] init];
    dynamicContent.action = action;
    dynamicContent.previewPropertyName = @"fitness:course";
    
    [FBSDKShareDialog showFromViewController:mvc
                                          withContent:dynamicContent
                                             delegate:nil];
}

@end
