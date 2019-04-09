#import "GPUImageTwoInputFilter.h"

extern NSString *const kGPUImageLightenBlendFragmentShaderString;

/// Blends two images by taking the maximum value of each color component between the images
@interface GPUImageLightenBlendFilter : GPUImageTwoInputFilter
{
}

@end
