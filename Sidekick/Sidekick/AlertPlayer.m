//
//  AlertPlayer.m
//  Sidekick
//
//  Created by Kathleen Feng on 7/23/15.
//  Copyright (c) 2015 thesquad. All rights reserved.
//

#import "AlertPlayer.h"

// File type of alert sound
NSString * const alertFileType = @"mp3";

@interface AlertPlayer ()

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) NSDictionary *alertCollection;

@end

@implementation AlertPlayer

+ (AlertPlayer *)sharedInstance {
    static AlertPlayer *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[AlertPlayer alloc] init];
    });
    
    return _sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self ) {
        _alertCollection = @{ @"0" : @"fun",
                              @"1" : @"letitgo",
                              @"2" : @"thatwaseasy",
                              @"3" : @"chimes",
                              @"4" : @"ringing",
                              @"5" : @"guitar",
                              @"6" : @"horn" };
        
        NSString *alert = [[NSUserDefaults standardUserDefaults] valueForKey:@"alertSounds"];
        NSString *soundPathName = [[NSBundle mainBundle] pathForResource:[_alertCollection valueForKey:alert] ofType:alertFileType];
        NSURL *alertSoundURL = [NSURL fileURLWithPath:soundPathName];
        
        _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:alertSoundURL
                                                              error:nil];
        
        [_audioPlayer setVolume:2.0];
    }
    return self;
}

- (void)play {
    [_audioPlayer play];
}

- (void)changeAlert {
    NSString *alert = [[NSUserDefaults standardUserDefaults] valueForKey:@"alertSounds"];
    NSString *soundPathName = [[NSBundle mainBundle] pathForResource:[_alertCollection valueForKey:alert] ofType:alertFileType];
    NSURL *alertSoundURL = [NSURL fileURLWithPath:soundPathName];
    
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:alertSoundURL
                                                          error:nil];
    
    [_audioPlayer setVolume:2.0];
}

@end
