#import "GPUImageFilter.h"

extern NSString *const kGPUImageOpacityFragmentShaderString;

@interface GPUImageOpacityFilter : GPUImageFilter
{
    GLint opacityUniform;
}

// Opacity ranges from 0.0 to 1.0, with 1.0 as the normal setting
@property(readwrite, nonatomic) CGFloat opacity;

@end
