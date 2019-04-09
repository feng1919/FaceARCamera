//
//  SettingView.m
//  BBFaceLandmarking
//
//  Created by Feng Stone on 2019/1/5.
//  Copyright © 2019 fengshi. All rights reserved.
//

#import "SettingView.h"

@interface SettingView ()

@property (nonatomic, strong) UISlider *sliderEyelarge;
@property (nonatomic, strong) UISlider *sliderFacelift;

- (void)eyelargeValueDidChange:(id)sender;
- (void)faceliftValueDidChange:(id)sender;
- (void)dismissButtonPressed:(id)sender;

@end

@implementation SettingView

+ (SettingView *)view {
    NSArray *xibObjects = [[NSBundle mainBundle] loadNibNamed:@"SettingView" owner:self options:nil];
    for (id obj in xibObjects) {
        if ([[obj class] isKindOfClass:self]) {
            return obj;
        }
    }
    return nil;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.eyelargeIntensity = _sliderEyelarge.value;
    self.faceliftIntensity = _sliderFacelift.value;
}

- (instancetype)init {
    if (self = [super initWithFrame:[[UIScreen mainScreen] bounds]]) {
        self.backgroundColor = [UIColor clearColor];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:@"" forState:UIControlStateNormal];
        [button setBackgroundColor:[UIColor clearColor]];
        [button setFrame:self.bounds];
        [button setAutoresizingMask:(UIViewAutoresizingFlexibleWidth |
                                     UIViewAutoresizingFlexibleHeight)];
        [button addTarget:self action:@selector(dismissButtonPressed:)
         forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame)-130, CGRectGetWidth(self.frame), 130)];
        contentView.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin|
                                        UIViewAutoresizingFlexibleWidth);
        [contentView setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:contentView];
        
        UILabel *labelEye = [[UILabel alloc] initWithFrame:CGRectMake(0, 24, 68, 21)];
        [labelEye setTextAlignment:NSTextAlignmentRight];
        [labelEye setText:@"大眼"];
        [labelEye setTextColor:[UIColor colorWithRed:20.0f/255.0
                                               green:40.0f/255.0f
                                                blue:80.0f/255.0f
                                               alpha:1.0f]];
        [labelEye setFont:[UIFont systemFontOfSize:16]];
        [contentView addSubview:labelEye];
        
        self.sliderEyelarge = [[UISlider alloc] initWithFrame:CGRectMake(87, 20, 266, 30)];
        [self.sliderEyelarge addTarget:self action:@selector(eyelargeValueDidChange:)
                      forControlEvents:UIControlEventValueChanged];
        self.sliderEyelarge.minimumValue = 0.0f;
        self.sliderEyelarge.maximumValue = 1.0f;
        self.sliderEyelarge.value = 0.5f;
        [contentView addSubview:self.sliderEyelarge];
        
        UILabel *labelFace = [[UILabel alloc] initWithFrame:CGRectMake(0, 84, 68, 21)];
        [labelFace setTextAlignment:NSTextAlignmentRight];
        [labelFace setText:@"瘦脸"];
        [labelFace setTextColor:[UIColor colorWithRed:20.0f/255.0
                                               green:40.0f/255.0f
                                                blue:80.0f/255.0f
                                               alpha:1.0f]];
        [labelFace setFont:[UIFont systemFontOfSize:16]];
        [contentView addSubview:labelFace];
        
        self.sliderFacelift = [[UISlider alloc] initWithFrame:CGRectMake(87, 80, 266, 30)];
        [self.sliderFacelift addTarget:self action:@selector(faceliftValueDidChange:)
                      forControlEvents:UIControlEventValueChanged];
        self.sliderFacelift.minimumValue = 0.0f;
        self.sliderFacelift.maximumValue = 1.0f;
        self.sliderFacelift.value = 0.5f;
        [contentView addSubview:self.sliderFacelift];
        
        self.eyelargeIntensity = _sliderEyelarge.value;
        self.faceliftIntensity = _sliderFacelift.value;
    }
    return self;
}

- (IBAction)eyelargeValueDidChange:(id)sender {
    self.eyelargeIntensity = _sliderEyelarge.value;
    [_delegate SettingView:self didChangeEyelargeIntensity:_eyelargeIntensity];
}

- (IBAction)faceliftValueDidChange:(id)sender {
    self.faceliftIntensity = _sliderFacelift.value;
    [_delegate SettingView:self didChangeFaceliftIntensity:_faceliftIntensity];
}

- (void)dismissButtonPressed:(id)sender {
    [self removeFromSuperview];
}

@end
