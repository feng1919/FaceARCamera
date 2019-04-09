//
//  FSLenFilter.m
//  BBFaceLandmarking
//
//  Created by Feng Stone on 2018/2/27.
//  Copyright © 2018年 fengshi. All rights reserved.
//

#import "FSLenFilter.h"

@implementation FSLenFilter

- (void)newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex {
    static const GLfloat imageVertices[] = {
        -1.0f, -1.0f,
        1.0f, -1.0f,
        -1.0f,  1.0f,
        1.0f,  1.0f,
    };
    
    [self renderToTextureWithVertices:imageVertices
                   textureCoordinates:[[self class] textureCoordinatesForRotation:inputRotation]];
    
//    [outputFramebuffer lock];
//    CGImageRef imageRef = [outputFramebuffer newCGImageFromFramebufferContents];
//    UIImage *image = [UIImage imageWithCGImage:imageRef];
//    
    [self informTargetsAboutNewFrameAtTime:frameTime];
}

- (void)informTargetsAboutNewFrameAtTime1:(CMTime)frameTime;
{
    if (self.frameProcessingCompletionBlock != NULL)
    {
        self.frameProcessingCompletionBlock(self, frameTime);
    }
    
    // Get all targets the framebuffer so they can grab a lock on it
    for (id<GPUImageInput> currentTarget in targets)
    {
        if (currentTarget != self.targetToIgnoreForUpdates)
        {
            NSInteger indexOfObject = [targets indexOfObject:currentTarget];
            NSInteger textureIndex = [[targetTextureIndices objectAtIndex:indexOfObject] integerValue];
            
            [self setInputFramebufferForTarget:currentTarget atIndex:textureIndex];
            [currentTarget setInputSize:[self outputFrameSize] atIndex:textureIndex];
        }
    }
    
    // Release our hold so it can return to the cache immediately upon processing
    [[self framebufferForOutput] unlock];
    
    if (usingNextFrameForImageCapture)
    {
        //        usingNextFrameForImageCapture = NO;
    }
    else
    {
        [self removeOutputFramebuffer];
    }
    
    NSLog(@"informTargetsAboutNewFrameAtTime %d", dispatch_get_specific([GPUImageContext sharedContextKey]) != NULL);
    
    // Trigger processing last, so that our unlock comes first in serial execution, avoiding the need for a callback
    for (id<GPUImageInput> currentTarget in targets)
    {
        if (currentTarget != self.targetToIgnoreForUpdates)
        {
            NSInteger indexOfObject = [targets indexOfObject:currentTarget];
            NSInteger textureIndex = [[targetTextureIndices objectAtIndex:indexOfObject] integerValue];
            
            [currentTarget newFrameReadyAtTime:frameTime atIndex:textureIndex];
        }
    }
}

@end
