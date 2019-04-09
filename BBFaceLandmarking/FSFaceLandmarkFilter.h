//
//  FSFaceLandmarkFilter.h
//  BBFaceLandmarking
//
//  Created by Feng Stone on 2018/2/21.
//  Copyright © 2018年 fengshi. All rights reserved.
//

#import "GPUImage/GPUImageFilter.h"
#import "DLibFaceFeatureStruct.h"

@protocol FSFaceLandmarkFilterDelegate;
@interface FSFaceLandmarkFilter : GPUImageFilter

@property (nonatomic, assign) id<FSFaceLandmarkFilterDelegate> delegate;
@property (atomic, assign) CGRect faceRect;
@property (atomic, assign) DLibFaceKeyPoints keyPoints;

@end

@protocol FSFaceLandmarkFilterDelegate<NSObject>
@optional
- (void)FSFaceLandmarkFilter:(FSFaceLandmarkFilter *)landmark didUpdateFacePoints:(DLibFaceKeyPoints)facePoints;
- (void)FSFaceLandmarkFilter:(FSFaceLandmarkFilter *)landmark didUpdateFaceRect:(CGRect)faceRect;

@end
