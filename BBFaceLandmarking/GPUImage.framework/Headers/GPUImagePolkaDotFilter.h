#import "GPUImagePixellateFilter.h"

extern NSString *const kGPUImagePolkaDotFragmentShaderString;

@interface GPUImagePolkaDotFilter : GPUImagePixellateFilter
{
    GLint dotScalingUniform;
}

@property(readwrite, nonatomic) CGFloat dotScaling;

@end
