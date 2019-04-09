#import "GPUImageFilter.h"

extern NSString *const kGPUImageRedHistogramSamplingVertexShaderString;
extern NSString *const kGPUImageGreenHistogramSamplingVertexShaderString;
extern NSString *const kGPUImageBlueHistogramSamplingVertexShaderString;
extern NSString *const kGPUImageLuminanceHistogramSamplingVertexShaderString;
extern NSString *const kGPUImageHistogramAccumulationFragmentShaderString;

typedef enum { kGPUImageHistogramRed, kGPUImageHistogramGreen, kGPUImageHistogramBlue, kGPUImageHistogramRGB, kGPUImageHistogramLuminance} GPUImageHistogramType;

@interface GPUImageHistogramFilter : GPUImageFilter
{
    GPUImageHistogramType histogramType;
    
    GLubyte *vertexSamplingCoordinates;
    
    GLProgram *secondFilterProgram, *thirdFilterProgram;
    GLint secondFilterPositionAttribute, thirdFilterPositionAttribute;
}

// Rather than sampling every pixel, this dictates what fraction of the image is sampled. By default, this is 16 with a minimum of 1.
@property(readwrite, nonatomic) NSUInteger downsamplingFactor;

// Initialization and teardown
- (id)initWithHistogramType:(GPUImageHistogramType)newHistogramType;
- (void)initializeSecondaryAttributes;

@end
