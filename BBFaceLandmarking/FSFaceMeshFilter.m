//
//  FSFaceMeshFilter.m
//  BBFaceLandmarking
//
//  Created by Feng Stone on 2019/1/5.
//  Copyright © 2019 fengshi. All rights reserved.
//

#import "FSFaceMeshFilter.h"
#include "Delaunay/delaunay.h"

const CGFloat MAX_EYE_DELTA_PIXEL = 5.0f;
const CGFloat MAX_FACE_DELTA_PIXEL = 10.0f;

@implementation FSFaceMeshFilter

- (instancetype)init {
    if (self = [super init]) {
        self.eyelargeIntensity = 0.0f;
        self.faceliftIntensity = 0.0f;
    }
    return self;
}

- (void)newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex;
{
    if (_faceRect.size.width == 0 || _faceRect.size.height == 0 ||
        inputTextureSize.width == 0 || inputTextureSize.height == 0) {
        outputFramebuffer = firstInputFramebuffer;
        [outputFramebuffer lock];
        [firstInputFramebuffer unlock];
    }
    else {

        CGFloat width = inputTextureSize.width;
        CGFloat height = inputTextureSize.height;

        int num_of_points = _facePoints->num_of_points + 8;
        point *normalized_points = malloc(num_of_points * sizeof(point));

        for (int i = 0; i < _facePoints->num_of_points; i++) {
            CGPoint p = _facePoints->points[i];
            normalized_points[i].x = MIN(MAX(p.x, 0.0f), width-1.0f) / width;
            normalized_points[i].y = MIN(MAX(p.y, 0.0f), height-1.0f) / height;
        }
        normalized_points[num_of_points-4].x = 0.0f;
        normalized_points[num_of_points-4].y = 0.0f;
        normalized_points[num_of_points-4].z = 0.0f;
        normalized_points[num_of_points-3].x = 0.0f;
        normalized_points[num_of_points-3].y = 1.0f;
        normalized_points[num_of_points-3].z = 0.0f;
        normalized_points[num_of_points-2].x = 1.0f;
        normalized_points[num_of_points-2].y = 1.0f;
        normalized_points[num_of_points-2].z = 0.0f;
        normalized_points[num_of_points-1].x = 1.0f;
        normalized_points[num_of_points-1].y = 0.0f;
        normalized_points[num_of_points-1].z = 0.0f;

        CGFloat min_x = CGRectGetMinX(_faceRect)/width;
        CGFloat max_x = CGRectGetMaxX(_faceRect)/width;
//        CGFloat mid_x = CGRectGetMidX(_faceRect)/width;
        CGFloat min_y = CGRectGetMinY(_faceRect)/height;
        CGFloat max_y = CGRectGetMaxY(_faceRect)/height;
//        CGFloat mid_y = CGRectGetMidY(_faceRect)/height;
        
        normalized_points[num_of_points-5].x = min_x;
        normalized_points[num_of_points-5].y = min_y;
        normalized_points[num_of_points-5].z = 0.0f;
        normalized_points[num_of_points-6].x = min_x;
        normalized_points[num_of_points-6].y = max_y;
        normalized_points[num_of_points-6].z = 0.0f;
        normalized_points[num_of_points-7].x = max_x;
        normalized_points[num_of_points-7].y = max_y;
        normalized_points[num_of_points-7].z = 0.0f;
        normalized_points[num_of_points-8].x = max_x;
        normalized_points[num_of_points-8].y = min_y;
        normalized_points[num_of_points-8].z = 0.0f;
//        normalized_points[num_of_points-9].x = mid_x;
//        normalized_points[num_of_points-9].y = min_y;
//        normalized_points[num_of_points-9].z = 0.0f;
//        normalized_points[num_of_points-10].x = max_x;
//        normalized_points[num_of_points-10].y = mid_y;
//        normalized_points[num_of_points-10].z = 0.0f;
//        normalized_points[num_of_points-11].x = mid_x;
//        normalized_points[num_of_points-11].y = max_y;
//        normalized_points[num_of_points-11].z = 0.0f;
//        normalized_points[num_of_points-12].x = min_x;
//        normalized_points[num_of_points-12].y = mid_y;
//        normalized_points[num_of_points-12].z = 0.0f;

        delaunay *d = delaunay_build(num_of_points, normalized_points, 0, NULL, 0, NULL);

        GLfloat *textureCoordinates = (GLfloat *)malloc(d->ntriangles * 6 * sizeof(GLfloat));
        for (int i = 0; i < d->ntriangles; i++) {
            triangle t = d->triangles[i];
            int index = i * 6;
            for (int j = 0; j < 3; j ++) {
                point p = normalized_points[t.vids[j]];
                textureCoordinates[index + j*2] = p.x;
                textureCoordinates[index + j*2 + 1] = p.y;
            }
        }

        CGFloat normalized_eye_delta_x = _eyelargeIntensity * MAX_EYE_DELTA_PIXEL / width;
        CGFloat normalized_eye_delta_y = _eyelargeIntensity * MAX_EYE_DELTA_PIXEL / height;
        CGFloat normalized_face_delta_x = _faceliftIntensity * MAX_FACE_DELTA_PIXEL / width;
        CGFloat normalized_face_delta_y = _faceliftIntensity * MAX_FACE_DELTA_PIXEL / height;
        CGFloat normalized_face_decay = 0.05f;

        GLfloat *imageVertices = (GLfloat *)malloc(d->ntriangles * 6 * sizeof(GLfloat));
        for (int i = 0; i < d->ntriangles; i++) {
            triangle t = d->triangles[i];
            int index = i * 6;
            for (int j = 0; j < 3; j ++) {
                int vid = t.vids[j];
                point p = normalized_points[vid];
                int eye_vid[2] = {36, 42};
                for (int eye = 0; eye < 2; eye ++) {
                    int ev = eye_vid[eye];
                    if (vid == ev+0) {
                        p.x -= normalized_eye_delta_x;
                    }
                    else if (vid == ev+1) {
                        p.y -= normalized_eye_delta_y;
                    }
                    else if (vid == ev+2) {
                        p.y -= normalized_eye_delta_y;
                    }
                    else if (vid == ev+3) {
                        p.x += normalized_eye_delta_x;
                    }
                    else if (vid == ev+4) {
                        p.y += normalized_eye_delta_y;
                    }
                    else if (vid == ev+5) {
                        p.y += normalized_eye_delta_y;
                    }
                }

                if (vid == 0) {
                    p.x += normalized_face_delta_x;
                }
                else if (vid == 1) {
                    p.x += normalized_face_delta_x * (1.0 - normalized_face_decay * 1.0f);
                    p.y -= normalized_face_delta_y * 0.05;
                }
                else if (vid == 2) {
                    p.x += normalized_face_delta_x * (1.0 - normalized_face_decay * 2.0f);
                }
                else if (vid == 3) {
                    p.x += normalized_face_delta_x * (1.0 - normalized_face_decay * 3.0f);
                }
                else if (vid == 4) {
                    p.x += normalized_face_delta_x * (1.0 - normalized_face_decay * 4.0f);
                }
                else if (vid == 5) {
                    p.x += normalized_face_delta_x * (1.0 - normalized_face_decay * 5.0f);
                }
                else if (vid == 6) {
                    p.x += normalized_face_delta_x * (1.0 - normalized_face_decay * 6.0f);
                }
                else if (vid == 7) {
                    p.x += normalized_face_delta_x * (1.0 - normalized_face_decay * 7.0f);
                }
                else if (vid == 9) {
                    p.x -= normalized_face_delta_x * (1.0 - normalized_face_decay * 7.0f);
                }
                else if (vid == 10) {
                    p.x -= normalized_face_delta_x * (1.0 - normalized_face_decay * 6.0f);
                }
                else if (vid == 11) {
                    p.x -= normalized_face_delta_x * (1.0 - normalized_face_decay * 5.0f);
                }
                else if (vid == 12) {
                    p.x -= normalized_face_delta_x * (1.0 - normalized_face_decay * 4.0f);
                }
                else if (vid == 13) {
                    p.x -= normalized_face_delta_x * (1.0 - normalized_face_decay * 3.0f);
                }
                else if (vid == 14) {
                    p.x -= normalized_face_delta_x * (1.0 - normalized_face_decay * 2.0f);
                }
                else if (vid == 15) {
                    p.x -= normalized_face_delta_x * (1.0 - normalized_face_decay * 1.0f);
                    p.y -= normalized_face_delta_y * 0.05;
                }
                else if (vid == 16) {
                    p.x -= normalized_face_delta_x;
                }

                imageVertices[index + j*2] = p.x * 2.0 - 1.0;
                imageVertices[index + j*2 + 1] = p.y * 2.0 - 1.0;
            }
        }

        [self renderToTextureWithVertices:imageVertices
                       textureCoordinates:textureCoordinates
                             elementCount:d->ntriangles];

        delaunay_destroy(d);
        free(normalized_points);
        free(imageVertices);
        free(textureCoordinates);
    }

    [self informTargetsAboutNewFrameAtTime:frameTime];
}

- (void)renderToTextureWithVertices:(const GLfloat *)vertices
                 textureCoordinates:(const GLfloat *)textureCoordinates
                       elementCount:(int)elementCount
{
    if (self.preventRendering)
    {
        [firstInputFramebuffer unlock];
        return;
    }
    
    [GPUImageContext setActiveShaderProgram:filterProgram];
    
    outputFramebuffer = [[GPUImageContext sharedFramebufferCache] fetchFramebufferForSize:[self sizeOfFBO] textureOptions:self.outputTextureOptions onlyTexture:NO];
    [outputFramebuffer activateFramebuffer];
    if (usingNextFrameForImageCapture)
    {
        [outputFramebuffer lock];
    }
    
    [self setUniformsForProgramAtIndex:0];
    
    glClearColor(backgroundColorRed, backgroundColorGreen, backgroundColorBlue, backgroundColorAlpha);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glActiveTexture(GL_TEXTURE2);
    glBindTexture(GL_TEXTURE_2D, [firstInputFramebuffer texture]);
    
    glUniform1i(filterInputTextureUniform, 2);
    
    glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
    glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    
    glDrawArrays(GL_TRIANGLES, 0, elementCount*3);
    
    [firstInputFramebuffer unlock];
    
    if (usingNextFrameForImageCapture)
    {
        dispatch_semaphore_signal(imageCaptureSemaphore);
    }
}

@end
