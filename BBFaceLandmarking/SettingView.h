//
//  SettingView.h
//  BBFaceLandmarking
//
//  Created by Feng Stone on 2019/1/5.
//  Copyright © 2019 fengshi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SettingViewDelegate;
@interface SettingView : UIView

@property (nonatomic, weak) id<SettingViewDelegate> delegate;
@property (atomic, assign) CGFloat eyelargeIntensity;
@property (atomic, assign) CGFloat faceliftIntensity;

+ (SettingView *)view;

@end

@protocol SettingViewDelegate <NSObject>

@required
- (void)SettingView:(SettingView *)settingView didChangeEyelargeIntensity:(CGFloat)eyelargeIntensity;
- (void)SettingView:(SettingView *)settingView didChangeFaceliftIntensity:(CGFloat)faceliftIntensity;

@end

