//
//  FSFaceMeshFilter.h
//  BBFaceLandmarking
//
//  Created by Feng Stone on 2019/1/5.
//  Copyright © 2019 fengshi. All rights reserved.
//

#import "GPUImage/GPUImageFilter.h"
#import "DLibFaceFeatureStruct.h"

@interface FSFaceMeshFilter : GPUImageFilter

@property (atomic, assign) CGRect faceRect;//人脸区域，目前只支持一张人脸
@property (atomic, assign) DLibFaceKeyPoints *facePoints;//人脸特征点

@property (atomic, assign) CGFloat eyelargeIntensity;//大眼的强度
@property (atomic, assign) CGFloat faceliftIntensity;//瘦脸的强度

@end
