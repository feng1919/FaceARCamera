#import "GPUImageFilter.h"

extern NSString *const kGPUImageHistogramGeneratorVertexShaderString;
extern NSString *const kGPUImageHistogramGeneratorFragmentShaderString;

@interface GPUImageHistogramGenerator : GPUImageFilter
{
    GLint backgroundColorUniform;
}

@end
