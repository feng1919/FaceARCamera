
#import "GPUImageFilter.h"

extern NSString *const kGPUImageHueFragmentShaderString;

@interface GPUImageHueFilter : GPUImageFilter
{
    GLint hueAdjustUniform;
    
}
@property (nonatomic, readwrite) CGFloat hue;

@end
