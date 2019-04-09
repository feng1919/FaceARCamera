//
//  ViewController.m
//  BBFaceLandmarking
//
//  Created by Feng Stone on 2018/2/8.
//  Copyright © 2018年 fengshi. All rights reserved.
//

#import "ViewController.h"
//#import "FSFaceDetectorFilter.h"
//#import "FSResizeFilter.h"
//#import "FSFaceLandmarkFilter.h"

//#import "FSFaceItem.h"
#import "FSPipelineManager.h"
#import "SettingView.h"
//#import "AverageFaceConfigView.h"

@interface ViewController () <SettingViewDelegate>

@property (nonatomic, strong) GPUImageVideoCamera *videoCamera;
@property (nonatomic, strong) GPUImageView *imageView;
@property (nonatomic, strong) FSPipelineManager *pipelineManager;
@property (nonatomic, strong) SettingView *settingView;
//@property (nonatomic, strong) AverageFaceConfigView *configView;

//- (void)settingButtonPressed:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.pipelineManager = [[FSPipelineManager alloc] init];
    
    self.imageView = _pipelineManager.imageView;
    self.imageView.frame = self.view.bounds;
    [self.view addSubview:self.imageView];
    
    self.videoCamera = [_pipelineManager videoCamera];
    
//    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    [button setFrame:CGRectMake(CGRectGetWidth(self.view.frame)*0.5, CGRectGetHeight(self.view.frame)-60, 100, 50)];
//    [button setAutoresizingMask:(UIViewAutoresizingFlexibleBottomMargin |
//                                 UIViewAutoresizingFlexibleLeftMargin)];
//    [button setTitle:@"设置" forState:UIControlStateNormal];
//    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [button addTarget:self action:@selector(settingButtonPressed:)
//     forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:button];
    
//    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    [button1 setFrame:CGRectMake(CGRectGetWidth(self.view.frame)*0.5+10, CGRectGetHeight(self.view.frame)-60, 100, 50)];
//    [button1 setAutoresizingMask:(UIViewAutoresizingFlexibleBottomMargin |
//                                 UIViewAutoresizingFlexibleLeftMargin)];
//    [button1 setTitle:@"平均脸" forState:UIControlStateNormal];
//    [button1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [button1 addTarget:self action:@selector(averageFaceButtonPressed:)
//     forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:button1];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
    [self.pipelineManager updateFilterPipeline];
    [self.videoCamera startCameraCapture];
    
//    NSString *folder = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"video_rabbit"];
//    FSFaceItem *faceItem = [[FSFaceItem alloc] initWithDirectory:folder resId:@"video_rabbit"];
//    [self.pipelineManager setFaceItem:faceItem];
    
    self.settingView.frame = self.view.bounds;
    [self.view addSubview:self.settingView];
}

- (SettingView *)settingView {
    if (!_settingView) {
        _settingView = [[SettingView alloc] init];
        _settingView.delegate = self;
    }
    return _settingView;
}

//- (AverageFaceConfigView *)configView {
//    if (!_configView) {
//        _configView = [[AverageFaceConfigView alloc] init];
//        _configView.delegate = self;
//    }
//    return _configView;
//}

//- (void)settingButtonPressed:(id)sender {
//    self.settingView.frame = self.view.bounds;
//    [self.view addSubview:self.settingView];
//}

//- (void)averageFaceButtonPressed:(id)sender {
//    self.configView.frame = self.view.bounds;
//    [self.view addSubview:self.configView];
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - SettingViewDelegate

- (void)SettingView:(SettingView *)settingView didChangeEyelargeIntensity:(CGFloat)eyelargeIntensity {
    _pipelineManager.eyelargeIntensity = eyelargeIntensity;
}

- (void)SettingView:(SettingView *)settingView didChangeFaceliftIntensity:(CGFloat)faceliftIntensity {
    _pipelineManager.faceliftIntensity = faceliftIntensity;
}

//#pragma mark - AverageFaceViewDelegate
//
//- (void)AverageFaceConfigView:(AverageFaceConfigView *)settingView enableAverageFace:(BOOL)enable {
//
//}
//
//- (void)AverageFaceConfigView:(AverageFaceConfigView *)settingView didChangeAverageFaceShapeIntensity:(CGFloat)shapeIntensity {
//
//}
//
//- (void)AverageFaceConfigView:(AverageFaceConfigView *)settingView didChangeAverageFaceSkinIntensity:(CGFloat)skinIntensity {
//
//}

@end
