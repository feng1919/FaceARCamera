//
//  FSResizeFilter.m
//  BBFaceLandmarking
//
//  Created by Feng Stone on 2018/2/11.
//  Copyright © 2018年 fengshi. All rights reserved.
//

#import "FSResizeFilter.h"

@implementation FSResizeFilter

- (instancetype)init {
    if (self = [super init]) {
        GPUTextureOptions textureOptions = self.outputTextureOptions;
        textureOptions.format = GL_RGBA;
        self.outputTextureOptions = textureOptions;
        self.scale = 1.0;
    }
    return self;
}

- (CGSize)maximumOutputSize {
    return CGSizeMake(roundf(inputTextureSize.width*_scale), roundf(inputTextureSize.height*_scale));
}

- (void)setScale:(CGFloat)scale {
    _scale = MIN(MAX(scale, 0.0f), 1.0f);
}

@end
