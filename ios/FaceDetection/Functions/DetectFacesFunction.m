/**
 * Copyright 2016 Marcel Piestansky (http://marpies.com)
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "FaceDetection.h"
#import "DetectFacesFunction.h"
#import <AIRExtHelpers/MPFREObjectUtils.h>
#import <AIRExtHelpers/MPStringUtils.h>
#import <AIRExtHelpers/FlashRuntimeExtensions.h>
#import <CoreImage/CoreImage.h>
#import "FaceDetectionHelper.h"
#import "FaceDetectionEvent.h"

FREObject fd_detectFaces( FREContext context, void* functionData, uint32_t argc, FREObject argv[] ) {
    FREObject imageObject = argv[0];
    FREBitmapData2 bitmapData;
    [FaceDetection log:@"fd_detectFaces"];
    
    int callbackId = [MPFREObjectUtils getInt:argv[1]];    
    if( FREAcquireBitmapData2( imageObject, &bitmapData ) == FRE_OK ) {
        int accuracy = [MPFREObjectUtils getInt:argv[2]];
        BOOL detectOpenEyes = [MPFREObjectUtils getBOOL: argv[3]];
        BOOL detectSmile = [MPFREObjectUtils getBOOL: argv[4]];
        
        [[FaceDetectionHelper sharedInstance] detectFaces:bitmapData accuracy:accuracy detectOpenEyes:detectOpenEyes detectSmile:detectSmile callbackId:callbackId];
        FREReleaseBitmapData( imageObject );
    } else {
        [FaceDetection log:@"Error acquiring BitmapData"];
        [FaceDetection dispatchEvent:FACE_DETECTION_ERROR withMessage:[MPStringUtils getEventErrorJSONString:callbackId errorMessage:@"Error acquiring BitmapData"]];
    }
    return nil;
}






