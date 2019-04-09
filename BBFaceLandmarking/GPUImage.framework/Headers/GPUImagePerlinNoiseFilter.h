#import "GPUImageFilter.h"

extern NSString *const kGPUImagePerlinNoiseFragmentShaderString;

@interface GPUImagePerlinNoiseFilter : GPUImageFilter 
{
    GLint scaleUniform, colorStartUniform, colorFinishUniform;
}

@property (readwrite, nonatomic) GPUVector4 colorStart;
@property (readwrite, nonatomic) GPUVector4 colorFinish;

@property (readwrite, nonatomic) float scale;

@end
