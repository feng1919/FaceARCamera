//
//  FSPipelineManager.h
//  BBFaceLandmarking
//
//  Created by Feng Stone on 2018/2/22.
//  Copyright © 2018年 fengshi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPUImage/GPUImageView.h"
#import "GPUImage/GPUImageVideoCamera.h"
//#import "FSFaceItem.h"

@interface FSPipelineManager : NSObject

@property (nonatomic, strong) GPUImageView *imageView;
@property (nonatomic, strong) GPUImageVideoCamera *videoCamera;
//@property (nonatomic, strong) FSFaceItem *faceItem;

@property (nonatomic, assign) CGFloat eyelargeIntensity;//大眼的强度
@property (nonatomic, assign) CGFloat faceliftIntensity;//瘦脸的强度

- (void)updateFilterPipeline;

@end
