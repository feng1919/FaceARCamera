//
//  FSPipelineManager.m
//  BBFaceLandmarking
//
//  Created by Feng Stone on 2018/2/22.
//  Copyright © 2018年 fengshi. All rights reserved.
//

#import "FSPipelineManager.h"
#import "FSFaceLandmarkFilter.h"
#import "FSResizeFilter.h"
//#import "FSFaceFilterPipeline.h"
#import "FSLenFilter.h"
#import "FSFaceMeshFilter.h"

@interface FSPipelineManager() <GPUImageVideoCameraDelegate, FSFaceLandmarkFilterDelegate>

@property (nonatomic, strong) FSFaceLandmarkFilter *landmarkDetector;
@property (nonatomic, strong) FSResizeFilter *resizeFilter;
@property (nonatomic, strong) GPUImageFilter *len;
//@property (nonatomic, strong) FSFaceFilterPipeline *filtersPipeline;
@property (nonatomic, strong) FSFaceMeshFilter *faceMeshFilter;

@property (atomic, assign) CGRect faceRect;
@property (atomic, assign) DLibFaceKeyPoints key_points;

@end

@implementation FSPipelineManager

- (instancetype)init {
    if (self = [super init]) {
        self.landmarkDetector = [[FSFaceLandmarkFilter alloc] init];
        self.landmarkDetector.delegate = self;
        self.resizeFilter = [[FSResizeFilter alloc] init];
        self.resizeFilter.scale = 1.0f;
        self.faceMeshFilter = [[FSFaceMeshFilter alloc] init];
        
        [self imageView];
        [self videoCamera];
        [self len];
//        [self histEqualFilter];
    }
    return self;
}

- (GPUImageView *)imageView {
    if (!_imageView) {
        _imageView = [[GPUImageView alloc] init];
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _imageView.fillMode = kGPUImageFillModePreserveAspectRatio;
        _imageView.backgroundColor = [UIColor blackColor];
    }
    return _imageView;
}

- (GPUImageVideoCamera *)videoCamera {
    if (!_videoCamera) {
        _videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1280x720
                                                          cameraPosition:AVCaptureDevicePositionFront];
        [_videoCamera setOutputImageOrientation:UIInterfaceOrientationPortrait];
//        [_videoCamera setDelegate:self];
        [_videoCamera setHorizontallyMirrorRearFacingCamera:NO];
        [_videoCamera setHorizontallyMirrorFrontFacingCamera:YES];
//        [_videoCamera enableMetaDataOutput];
    }
    return _videoCamera;
}

- (GPUImageFilter *)len {
    if (!_len) {
        _len = [[GPUImageFilter alloc] init];
    }
    return _len;
}

- (void)updateFilterPipeline {
    
    runAsynchronouslyOnVideoProcessingQueue(^{
        
        [self.videoCamera removeAllTargets];
        [self.landmarkDetector removeAllTargets];
        [self.resizeFilter removeAllTargets];
        [self.len removeAllTargets];
//        [self.filtersPipeline removeAllTargets];
        [self.faceMeshFilter removeAllTargets];
        
        [self.videoCamera addTarget:self.len];
        [self.len addTarget:self.resizeFilter];
        [self.resizeFilter addTarget:self.landmarkDetector];
        
//        [self.histEqualFilter addTarget:self.landmarkDetector];
        
        [self.len addTarget:self.faceMeshFilter];
        [self.faceMeshFilter addTarget:self.imageView];
        
//        if (self.filtersPipeline) {
//            [self.len addTarget:self.faceMeshFilter];
//            [self.faceMeshFilter addTarget:self.filtersPipeline];
//            [self.filtersPipeline addTarget:self.imageView];
//        }
//        else {
//            [self.len addTarget:self.imageView];
//        }
        
    });
}

//- (void)setFaceItem:(FSFaceItem *)faceItem {
//    _faceItem = faceItem;
//    
//    runAsynchronouslyOnVideoProcessingQueue(^{
//        self.filtersPipeline = [[FSFaceFilterPipeline alloc] initWithFaceItem:faceItem];
//        [self.filtersPipeline loadResource];
//        [self updateFilterPipeline];
//    });
//}

- (void)setEyelargeIntensity:(CGFloat)eyelargeIntensity {
    _faceMeshFilter.eyelargeIntensity = eyelargeIntensity;
}

- (CGFloat)eyelargeIntensity {
    return _faceMeshFilter.eyelargeIntensity;
}

- (void)setFaceliftIntensity:(CGFloat)faceliftIntensity {
    _faceMeshFilter.faceliftIntensity = faceliftIntensity;
}

- (CGFloat)faceliftIntensity {
    return _faceMeshFilter.faceliftIntensity;
}

#pragma mark - Detect face landmark

- (void)FSFaceLandmarkFilter:(FSFaceLandmarkFilter *)landmark didUpdateFaceRect:(CGRect)faceRect {
//    BOOL hasFace = !CGSizeEqualToSize(_faceRect.size, CGSizeZero);
//    BOOL hasFace1 = !CGSizeEqualToSize(faceRect.size, CGSizeZero);
    
    self.faceRect = faceRect;
//    if (hasFace^hasFace1) {
//        [self performSelectorOnMainThread:@selector(updateFilterPipeline) withObject:nil waitUntilDone:NO];
//    }
    
//    [self.filtersPipeline setFaceRect:faceRect];
    [self.faceMeshFilter setFaceRect:faceRect];
}

- (void)FSFaceLandmarkFilter:(FSFaceLandmarkFilter *)landmark didUpdateFacePoints:(DLibFaceKeyPoints)facePoints {
//    [self.filterPipelines makeObjectsPerformSelector:@selector(setFacePoints:) withObject:facePoints];
//    [self.filterPipelines makeObjectsPerformSelector:@selector(processResource) withObject:nil];
    self.key_points = facePoints;
//    [self.filtersPipeline setFacePoints:_key_points];
    [self.faceMeshFilter setFacePoints:&_key_points];
}

#pragma mark - GPUImageVideoCamera delegate

- (void)GPUImageVideoCamera:(GPUImageVideoCamera *)videoCamera
  willOutputMetaDataObjects:(NSArray<__kindof AVMetadataObject *> *)metaDataObjects {
    
    CGRect faceRect = CGRectMake(0, 0, 0, 0);
    AVMetadataObject *metaDataObj = metaDataObjects.firstObject;
    if ([metaDataObj isKindOfClass:[AVMetadataFaceObject class]]) {
        
        faceRect = [(AVMetadataFaceObject *)metaDataObj bounds];
        if (CGSizeEqualToSize(CGSizeZero, faceRect.size)) {
            NSAssert(NO, @"Zero face...");
        }
    }
    
    self.faceRect = faceRect;
    _landmarkDetector.faceRect = faceRect;
}

@end
