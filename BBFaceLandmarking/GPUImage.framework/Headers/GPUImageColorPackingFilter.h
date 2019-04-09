#import "GPUImageFilter.h"

extern NSString *const kGPUImageColorPackingVertexShaderString;
extern NSString *const kGPUImageColorPackingFragmentShaderString;

@interface GPUImageColorPackingFilter : GPUImageFilter
{
    GLint texelWidthUniform, texelHeightUniform;
    
    CGFloat texelWidth, texelHeight;
}

@end
