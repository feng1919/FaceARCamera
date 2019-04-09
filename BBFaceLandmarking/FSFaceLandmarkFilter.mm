//
//  FSFaceLandmarkFilter.m
//  BBFaceLandmarking
//
//  Created by Feng Stone on 2018/2/21.
//  Copyright © 2018年 fengshi. All rights reserved.
//

#import "FSFaceLandmarkFilter.h"

#import <CoreImage/CoreImage.h>
#import <CoreGraphics/CoreGraphics.h>

#include <dlib/image_processing.h>
#include <dlib/image_io.h>

#define PRINT_BENCHEMARK 0

using namespace dlib;

@interface FSFaceLandmarkFilter() {
    dispatch_queue_t face_detect_queue;
    array2d<rgb_alpha_pixel> image_buffer;
    shape_predictor sp;
    
    CIContext *faceDetectContext;
//    NSDictionary *faceDetectParams;
    CIDetector *faceDetector;
    BOOL face_detecting;
}

CGRect transformForFrontalFace(CGRect& faceBound);

@end

@implementation FSFaceLandmarkFilter

- (instancetype)init {
    if (self = [super init]) {
        face_detect_queue = dispatch_queue_create("com.fengshi.facedetectqueue", DISPATCH_QUEUE_PRIORITY_DEFAULT);
        face_detecting = NO;
        
        NSString *spName = @"shape_predictor_68_face_landmarks";
        NSString *modelFileName = [[NSBundle mainBundle] pathForResource:spName ofType:@"dat"];
        std::string modelFileNameCString = [modelFileName UTF8String];
        dlib::deserialize(modelFileNameCString) >> sp;
        
        faceDetectContext = [CIContext context];
//        faceDetectParams = @{CIDetectorImageOrientation : @(1)};
        faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace
                                          context:faceDetectContext
                                          options:@{ CIDetectorAccuracy : CIDetectorAccuracyHigh }];
    }
    return self;
}

- (void)newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex {
    
    int width = firstInputFramebuffer.size.width;
    int height = firstInputFramebuffer.size.height;
    if (width <= 0 || height <= 0) {
        [firstInputFramebuffer unlock];
        return;
    }
    
    if (num_rows(image_buffer) != height || num_columns(image_buffer) != width) {
        NSLog(@"reset image size: %dx%d", height, width);
        image_buffer.set_size(height, width);
    }
    
#if PRINT_BENCHEMARK
    printf("\n\n new image: %d %d %f",width, height, CACurrentMediaTime());
#endif
    
    [firstInputFramebuffer lockForReading];
    unsigned char *rawImagePixels = [firstInputFramebuffer byteBuffer];
    if (rawImagePixels == NULL) {
        [firstInputFramebuffer unlockAfterReading];
        [firstInputFramebuffer unlock];
        NSLog(@"Invalid raw image pixels");
        return;
    }
    NSUInteger rawImageBPR = [firstInputFramebuffer bytesPerRow];
    NSUInteger dstBPR = width * 4;
    unsigned char *imageDataBuffer = (unsigned char *)image_data(image_buffer);
    for (int i = 0; i < height; i ++) {
        memcpy(imageDataBuffer + dstBPR*i, rawImagePixels+rawImageBPR*i, dstBPR);
    }
    
    [firstInputFramebuffer unlockAfterReading];
    [firstInputFramebuffer unlock];
    
    if (!face_detecting) {
        face_detecting = YES;
        dispatch_async(face_detect_queue, ^{
#if PRINT_BENCHEMARK
            printf("\n core image create: %f", CACurrentMediaTime());
#endif
            static CGColorSpaceRef colorSpace = NULL;
            if (colorSpace == NULL) {
                colorSpace = CGColorSpaceCreateDeviceRGB();
            }
            NSData *imageData = [NSData dataWithBytes:imageDataBuffer length:dstBPR*height];
            CIImage *imageFromFramebuffer = [CIImage imageWithBitmapData:imageData
                                                             bytesPerRow:dstBPR
                                                                    size:CGSizeMake(width, height)
                                                                  format:kCIFormatRGBA8
                                                              colorSpace:colorSpace];
            
#if PRINT_BENCHEMARK
            printf("\n core image detect begin: %f", CACurrentMediaTime());
#endif
            NSArray *features = [faceDetector featuresInImage:imageFromFramebuffer options:nil];
#if PRINT_BENCHEMARK
            printf("\n core image detect end  : %f", CACurrentMediaTime());
#endif
            
            if (features.count == 0) {
                self.faceRect = CGRectZero;
            }
            else {
                CIFeature *feature = features.firstObject;
                CGRect faceRect = feature.bounds;
                faceRect.origin.y = height - faceRect.size.height - faceRect.origin.y;
                self.faceRect = faceRect;
            }
            
            if ([_delegate respondsToSelector:@selector(FSFaceLandmarkFilter:didUpdateFaceRect:)]) {
                [_delegate FSFaceLandmarkFilter:self didUpdateFaceRect:_faceRect];
            }
            
            face_detecting = NO;
        });
    }
    
    if (CGSizeEqualToSize(CGSizeZero, _faceRect.size)) {
        return;
    }
    
    dlib::rectangle oneFaceRect(_faceRect.origin.x, _faceRect.origin.y, CGRectGetMaxX(_faceRect), CGRectGetMaxY(_faceRect));
    
#if PRINT_BENCHEMARK
    printf("\n detect begin %f",CACurrentMediaTime());
#endif
    
    dlib::full_object_detection shape = sp(image_buffer, oneFaceRect);
    
#if PRINT_BENCHEMARK
    printf("\n detect end   %f",CACurrentMediaTime());
#endif
    
    NSAssert(shape.num_parts() == 68, @"Invalid shape parts count");
    
    DLibFaceKeyPoints keyPoints;
    keyPoints.num_of_points = 71;
    CGPoint *fp = keyPoints.points;
    for (int k = 0; k < shape.num_parts(); k++) {
        point p = shape.part(k);
        fp[k].x = p.x();
        fp[k].y = p.y();
    }
    fp[68].x = (fp[19].x+fp[24].x)*0.5f;
    fp[68].y = (fp[19].y+fp[24].y)*0.5f;
    fp[69].x = fp[68].x*2.0f-fp[27].x;
    fp[69].y = fp[68].y*2.0f-fp[27].y;
    fp[70].x = fp[68].x*2.0f-fp[30].x;
    fp[70].y = fp[68].y*2.0f-fp[30].y;
    
    if (self.keyPoints.num_of_points == 71) {
        for (int i = 0; i < 71; i ++) {
            fp[i].x = (_keyPoints.points[i].x + fp[i].x) * 0.5f;
            fp[i].y = (_keyPoints.points[i].y + fp[i].y) * 0.5f;
        }
    }
    self.keyPoints = keyPoints;
    
#if PRINT_BENCHEMARK
    printf("\n image process end %f\n", CACurrentMediaTime());
#endif
    
    if ([_delegate respondsToSelector:@selector(FSFaceLandmarkFilter:didUpdateFacePoints:)]) {
        [_delegate FSFaceLandmarkFilter:self didUpdateFacePoints:_keyPoints];
    }
}

+ (dlib::rectangle)convertCGRect:(CGRect)rect1 sizeInPixel:(CGSize)size {
//    std::vector<dlib::rectangle> myConvertedRects;
//    for (NSValue *rectValue in rects) {
//        CGRect rect1 = [rectValue CGRectValue];
    
        CGRect rect = transformForFrontalFace(rect1);
        
        long left = rect.origin.x * size.width;
        long top = rect.origin.y * size.height;
        long right = ceilf(CGRectGetMaxX(rect) * size.width);
        long bottom = ceilf(CGRectGetMaxY(rect) * size.height);
        dlib::rectangle dlibRect(left, top, right, bottom);
    
    return dlibRect;
        
//        myConvertedRects.push_back(dlibRect);
//    }
//    return myConvertedRects;
}

+ (std::vector<dlib::rectangle>)convertCGRectValueArray:(NSArray<NSValue *> *)rects sizeInPixel:(CGSize)size {
    std::vector<dlib::rectangle> myConvertedRects;
    for (NSValue *rectValue in rects) {
        CGRect rect1 = [rectValue CGRectValue];

        CGRect rect = transformForFrontalFace(rect1);
        
        long left = rect.origin.x * size.width;
        long top = rect.origin.y * size.height;
        long right = ceilf(CGRectGetMaxX(rect) * size.width);
        long bottom = ceilf(CGRectGetMaxY(rect) * size.height);
        dlib::rectangle dlibRect(left, top, right, bottom);
        
        myConvertedRects.push_back(dlibRect);
    }
    return myConvertedRects;
}

CGRect transformForFrontalFace(CGRect& faceBound) {
    CGRect rect;
    rect.origin.x = faceBound.origin.y;
    rect.origin.y = faceBound.origin.x;
    rect.size.width = faceBound.size.height;
    rect.size.height = faceBound.size.width;
    return rect;
}

@end
