#import "GPUImageTwoPassTextureSamplingFilter.h"

extern NSString *const kGPUImageLanczosVertexShaderString;
extern NSString *const kGPUImageLanczosFragmentShaderString;

@interface GPUImageLanczosResamplingFilter : GPUImageTwoPassTextureSamplingFilter

@property(readwrite, nonatomic) CGSize originalImageSize;

@end
