//
//  FSResizeFilter.h
//  BBFaceLandmarking
//
//  Created by Feng Stone on 2018/2/11.
//  Copyright © 2018年 fengshi. All rights reserved.
//

#import "GPUImage/GPUImageFilter.h"

@interface FSResizeFilter : GPUImageFilter

@property (nonatomic, assign) CGFloat scale;

@end
