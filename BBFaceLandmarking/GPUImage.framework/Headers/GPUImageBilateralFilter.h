#import "GPUImageGaussianBlurFilter.h"

extern NSString *const kGPUImageBilateralBlurVertexShaderString;
extern NSString *const kGPUImageBilateralFilterFragmentShaderString;

@interface GPUImageBilateralFilter : GPUImageGaussianBlurFilter
{
    CGFloat firstDistanceNormalizationFactorUniform;
    CGFloat secondDistanceNormalizationFactorUniform;
}
// A normalization factor for the distance between central color and sample color.
@property(nonatomic, readwrite) CGFloat distanceNormalizationFactor;
@end
