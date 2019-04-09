#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "GPUImageContext.h"

extern NSString *const kGPUImageColorSwizzlingFragmentShaderString;

@class GPUImageMovieWriter;
@protocol GPUImageMovieWriterDelegate <NSObject>

@optional
- (void)GPUImageMovieWriter:(GPUImageMovieWriter *)movieWriter didAppendVideoFrameAtTime:(CMTime)frameTime;
- (void)GPUImageMovieWriter:(GPUImageMovieWriter *)movieWriter didDropVideoFrameAtTime:(CMTime)frameTime;

- (void)GPUImageMovieWriter:(GPUImageMovieWriter *)movieWriter didAppendAudioFrameAtTime:(CMTime)frameTime;
- (void)GPUImageMovieWriter:(GPUImageMovieWriter *)movieWriter didDropAudioFrameAtTime:(CMTime)frameTime;

- (void)GPUImageMovieWriterDidComplete:(GPUImageMovieWriter *)movieWriter;
- (void)GPUImageMovieWriter:(GPUImageMovieWriter *)movieWriter didFailWithError:(NSError *)error;

@end

@interface GPUImageMovieWriter : NSObject <GPUImageInput>
{
    BOOL alreadyFinishedRecording;
    
    NSURL *movieURL;
    NSString *fileType;
	AVAssetWriter *assetWriter;
	AVAssetWriterInput *assetWriterAudioInput;
	AVAssetWriterInput *assetWriterVideoInput;
    AVAssetWriterInputPixelBufferAdaptor *assetWriterPixelBufferInput;
    
    GPUImageContext *_movieWriterContext;
    CVPixelBufferRef renderTarget;
    CVOpenGLESTextureRef renderTexture;

    CGSize videoSize;
    GPUImageRotationMode inputRotation;
}

@property(readwrite, nonatomic) BOOL hasAudioTrack;
@property(readwrite, nonatomic) BOOL shouldPassthroughAudio;
@property(readwrite, nonatomic) BOOL shouldInvalidateAudioSampleWhenDone;
/// Not thread safe
@property(readwrite, nonatomic) BOOL dropAudioFrameUntilNextVideoFrameEncoded;
@property(nonatomic, copy) void(^completionBlock)(void);
@property(nonatomic, copy) void(^failureBlock)(NSError*);
@property(nonatomic, weak) id<GPUImageMovieWriterDelegate> delegate;
@property(readwrite, nonatomic) BOOL encodingLiveVideo;
@property(nonatomic, copy) BOOL(^videoInputReadyCallback)(void);
@property(nonatomic, copy) BOOL(^audioInputReadyCallback)(void);
@property(nonatomic, copy) void(^audioProcessingCallback)(SInt16 **samplesRef, CMItemCount numSamplesInBuffer);
@property(nonatomic) BOOL enabled;
@property(nonatomic, readonly) AVAssetWriter *assetWriter;
@property(nonatomic, readonly) CMTime duration;
@property(nonatomic, assign) CGAffineTransform transform;
@property(nonatomic, copy) NSArray *metaData;
@property(nonatomic, assign, getter = isPaused) BOOL paused;
@property(nonatomic, retain) GPUImageContext *movieWriterContext;

// Initialization and teardown
- (id)initWithMovieURL:(NSURL *)newMovieURL size:(CGSize)newSize;
- (id)initWithMovieURL:(NSURL *)newMovieURL size:(CGSize)newSize fileType:(NSString *)newFileType outputSettings:(NSDictionary *)outputSettings;

- (void)setHasAudioTrack:(BOOL)hasAudioTrack audioSettings:(NSDictionary *)audioOutputSettings;

// Movie recording
- (BOOL)isRecording;
- (void)startRecording;
- (void)startRecordingInOrientation:(CGAffineTransform)orientationTransform;
- (void)finishRecording;
- (void)finishRecordingWithCompletionHandler:(void (^)(void))handler;
- (void)cancelRecording;
- (void)processAudioBuffer:(CMSampleBufferRef)audioBuffer;
- (void)enableSynchronizationCallbacks;

- (void)startSessionAtSourceTime:(CMTime)sourceTime;
- (void)endSessionAtSourceTime:(CMTime)sourceTime;
- (void)setOffsetTime:(CMTime)offsetTime;

@end
