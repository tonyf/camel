//
//  DisclaimerSubviewController.m
//  Sidekick
//
//  Created by Kathleen Feng on 7/23/15.
//  Copyright (c) 2015 thesquad. All rights reserved.
//

#import "DisclaimerSubviewController.h"
#import "IASKSpecifier.h"

@interface DisclaimerSubviewController ()

@property (nonatomic, strong) UILabel *label;

@end

#define PADDING 20

@implementation DisclaimerSubviewController

- (instancetype)initWithFile:(NSString *)file
                   specifier:(IASKSpecifier *)specifier {
    self = [super init];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"Disclaimer";
    
    _label = [[UILabel alloc] init];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"disclaimer" ofType:@"txt"];
    _label.text = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    _label.numberOfLines = 0;
    
    [self.view addSubview:_label];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    float navBar = self.navigationController.navigationBar.frame.size.height;
    _label.frame = CGRectMake(PADDING, navBar + PADDING, self.view.bounds.size.width - 2 * PADDING, self.view.bounds.size.height - navBar - PADDING);
    
    [_label sizeToFit];
}

@end
