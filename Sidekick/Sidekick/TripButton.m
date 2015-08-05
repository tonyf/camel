//
//  TripButton.m
//  Sidekick
//
//  Created by Tony Francis on 7/23/15.
//  Copyright (c) 2015 thesquad. All rights reserved.
//

#import "TripButton.h"

#define TOP_TEXT_PADDING 15

@implementation TripButton

-(void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect imageFrame = self.imageView.frame;
    imageFrame.origin.y = 0;
    imageFrame.origin.x = (self.frame.size.width / 2) - (imageFrame.size.width / 2);
    self.imageView.frame = imageFrame;
    

    CGRect titleLabelFrame = self.titleLabel.frame;
    CGSize size = CGSizeMake(self.frame.size.width, CGFLOAT_MAX);
    CGRect textRect = [self.titleLabel.text boundingRectWithSize:size
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:@{NSFontAttributeName:self.titleLabel.font}
                                         context:nil];
    CGSize labelSize = textRect.size;
    
    titleLabelFrame.size.width = labelSize.width;
    titleLabelFrame.size.height = labelSize.height;
    titleLabelFrame.origin.x = (self.frame.size.width / 2) - (labelSize.width / 2);
    titleLabelFrame.origin.y = self.imageView.frame.origin.y + self.imageView.frame.size.height + TOP_TEXT_PADDING;
    self.titleLabel.frame = titleLabelFrame;
    
}

@end
