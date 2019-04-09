//
//  DLibFaceFeatureStruct.h
//  BBFaceLandmarking
//
//  Created by Feng Stone on 2019/1/6.
//  Copyright © 2019 fengshi. All rights reserved.
//

//#if __cplusplus
//extern "C" {
//#endif

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

#ifndef DLibFaceFeatureStruct_h
#define DLibFaceFeatureStruct_h

typedef struct DLibFaceKeyPoints {
    int num_of_points;
    CGPoint points[71];
} DLibFaceKeyPoints;

typedef struct DLibFaceStruct {
    int VIDS_LF[9];
    int VIDS_RF[9];
    int VIDS_LE[6];
    int VIDS_LEB[5];
    int VIDS_RE[6];
    int VIDS_REB[5];
    int VIDS_NU[4];
    int VIDS_ND[5];
    int VIDS_MU[12];
    int VIDS_MD[12];
} DLibFaceStruct;
extern DLibFaceStruct DLibDefaultFaceStruct;

typedef struct DLibFaceFeatures {
    CGPoint feature_point;
    CGVector feature_list[12];
    int num_of_features;
}DLibFaceFeatures;

#endif /* DLibFaceFeatureStruct_h */

//#if __cplusplus
//}   // Extern C
//#endif
