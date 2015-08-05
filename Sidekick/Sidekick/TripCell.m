//
//  TripCell.m
//  Sidekick
//
//  Created by Tony Francis on 7/20/15.
//  Copyright (c) 2015 thesquad. All rights reserved.
//

#import "TripCell.h"



#define DROP_DOWN_TIME 1
#define DAMPING 5
#define INFO_VIEW_HEIGHT 80

@interface TripCell ()
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, assign) BOOL isShowingOptions;
@end

@implementation TripCell
@synthesize delegate;

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self _setupGestureRecognizer];
        _isShowingOptions = NO;
    }
    return self;
}

- (void)_setupGestureRecognizer {
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userDidTap)];
    _tapGestureRecognizer.numberOfTapsRequired = 1;
    [self addGestureRecognizer:_tapGestureRecognizer];
}

- (void)userDidTap {
    if (_isShowingOptions) {
        _isShowingOptions = !_isShowingOptions;
        [self hideOptions];
    } else {
        _isShowingOptions = !_isShowingOptions;
        [self showOptions];
    }
}

- (void)showOptions {
    [_startRouteButton setAlpha:0.0];
    [_startRouteButton setHidden:NO];
    [_startRouteButton setEnabled:YES];
    [_startRouteButton setUserInteractionEnabled:YES];
    
    [_shareRouteButton setAlpha:0.0];
    [_shareRouteButton setHidden:NO];
    [_shareRouteButton setEnabled:YES];
    [_shareRouteButton setUserInteractionEnabled:YES];
    
    [UIView animateWithDuration:DROP_DOWN_TIME delay:0 usingSpringWithDamping:DAMPING initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        _infoView.frame = CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height);
        [self.startRouteButton setAlpha:1.0];
        [self.shareRouteButton setAlpha:1.0];
    } completion:nil];
}

- (void)hideOptions {
    [UIView animateWithDuration:DROP_DOWN_TIME/2 delay:0 usingSpringWithDamping:DAMPING initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [self.startRouteButton setAlpha:0.0];
        [self.shareRouteButton setAlpha:0.0];
    } completion:nil];
    
    [UIView animateWithDuration:DROP_DOWN_TIME delay:0 usingSpringWithDamping:DAMPING initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        _infoView.frame = CGRectMake(self.contentView.frame.origin.x, self.contentView.frame.origin.y, self.contentView.frame.size.width, INFO_VIEW_HEIGHT);
        
    } completion:^(BOOL succeed) {
        [_startRouteButton setUserInteractionEnabled:NO];
        [_startRouteButton setHidden:YES];
        [_startRouteButton setEnabled:NO];
        
        [_shareRouteButton setUserInteractionEnabled:NO];
        [_shareRouteButton setHidden:YES];
        [_shareRouteButton setEnabled:NO];
    }];
}

- (IBAction)didPressStartRoute:(UIButton *)sender {
    [self.delegate startButtonWasPressedForCellAtIndexPath:_indexPath];
}

- (IBAction)didPressShareRoute:(id)sender {
    [self.delegate shareButtonWasPressedForCellAtIndexPath:_indexPath];
}

@end
