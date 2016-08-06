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

#import "FaceDetectionHelper.h"
#import "FaceDetection.h"
#import "FaceDetectionEvent.h"
#import <ImageIO/ImageIO.h>
#import <AIRExtHelpers/MPStringUtils.h>

static const int kFaceDetectionAccuracyLow = 0;
static const int kFaceDetectionAccuracyHigh = 1;

static FaceDetectionHelper* airFdSharedInstance = nil;

@implementation FaceDetectionHelper

+ (nonnull id) sharedInstance {
    if( airFdSharedInstance == nil ) {
        airFdSharedInstance = [[FaceDetectionHelper alloc] init];
    }
    return airFdSharedInstance;
}

- (void) detectFaces:(FREBitmapData2) bitmap accuracy:(int) accuracy detectOpenEyes:(BOOL) detectOpenEyes detectSmile:(BOOL) detectSmile callbackId:(int) callbackId {
    [FaceDetection log:@"FaceDetectionHelper::detectFaces"];
    
    dispatch_async( dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 ), ^{
        CIImage* coreImage = [[CIImage alloc] initWithCGImage:[self getCGImageRefFromFREBitmapData:bitmap]];
        
        CIContext* context = [CIContext contextWithOptions:nil];
        NSDictionary* config = @{ CIDetectorAccuracy : (accuracy == kFaceDetectionAccuracyHigh) ? CIDetectorAccuracyHigh : CIDetectorAccuracyLow };
        CIDetector* detector = [CIDetector detectorOfType:CIDetectorTypeFace
                                                  context:context
                                                  options:config];
        
        NSMutableDictionary* opts = [NSMutableDictionary dictionary];
        if( [[coreImage properties] valueForKey:kCGImagePropertyOrientation] != nil ) {
            opts[CIDetectorImageOrientation] = [[coreImage properties] valueForKey:kCGImagePropertyOrientation];
        }
        if( detectOpenEyes ) {
            opts[CIDetectorEyeBlink] = @(YES);
        }
        if( detectSmile ) {
            opts[CIDetectorSmile] = @(YES);
        }
        
        // Y positions have origin at the bottom
        uint32_t imageHeight = bitmap.height;
        NSArray* features = [detector featuresInImage:coreImage options:opts];
        [FaceDetection log:[NSString stringWithFormat:@"Got CGImage and num of faces: %lu", (unsigned long)[features count]]];
        NSMutableArray* facesResult = [NSMutableArray array];
        for( CIFaceFeature* face in features ) {
            if( [FaceDetection isLogEnabled] ) {
                [self printFace:face imageHeight:imageHeight];
            }
            [facesResult addObject:[self getFaceJSON:face imageHeight:imageHeight]];
        }
        
        dispatch_async( dispatch_get_main_queue(), ^{
            NSMutableDictionary* response = [NSMutableDictionary dictionary];
            response[@"faces"] = facesResult;
            response[@"callbackId"] = @(callbackId);
            [FaceDetection dispatchEvent:FACE_DETECTION_COMPLETE withMessage:[MPStringUtils getJSONString:response]];
        });
    });
}

- (NSString*) getFaceJSON:(CIFaceFeature*) face imageHeight:(uint32_t) imageHeight {
    NSMutableDictionary* json = [NSMutableDictionary dictionary];
    json[@"faceX"] = @(face.bounds.origin.x);
    json[@"faceY"] = @(imageHeight - face.bounds.origin.y - face.bounds.size.height);
    json[@"faceWidth"] = @(face.bounds.size.width);
    json[@"faceHeight"] = @(face.bounds.size.height);
    json[@"leftEyeOpenProbability"] = face.leftEyeClosed ? @(0) : @(1);
    json[@"rightEyeOpenProbability"] = face.rightEyeClosed ? @(0) : @(1);
    json[@"isSmilingProbability"] = face.hasSmile ? @(1) : @(0);
    /* Eye position is returned as relative to the subject, i.e. left
     * eye position given by the detector is the subject's right eye.  */
    if( face.hasLeftEyePosition ) {
        json[@"rightEyeX"] = @(face.leftEyePosition.x);
        json[@"rightEyeY"] = @(imageHeight - face.leftEyePosition.y);
    }
    if( face.hasRightEyePosition ) {
        json[@"leftEyeX"] = @(face.rightEyePosition.x);
        json[@"leftEyeY"] = @(imageHeight - face.rightEyePosition.y);
    }
    if( face.hasMouthPosition ) {
        json[@"mouthX"] = @(face.mouthPosition.x);
        json[@"mouthY"] = @(imageHeight - face.mouthPosition.y);
    }
    return [MPStringUtils getJSONString:json];
}

- (CGImageRef) getCGImageRefFromFREBitmapData:(FREBitmapData2) bitmapData {
    size_t width = bitmapData.width;
    size_t height = bitmapData.height;
    
    CGDataProviderRef provider = CGDataProviderCreateWithData( NULL, bitmapData.bits32, (width * height * 4), NULL );
    
    size_t bitsPerComponent = 8;
    size_t bitsPerPixel = 32;
    size_t bytesPerRow = 4 * width;
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo;
    
    if( bitmapData.hasAlpha ) {
        if( bitmapData.isPremultiplied ) {
            bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst;
        } else {
            bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaFirst;
        }
    } else {
        bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipFirst;
    }
    
    CGImageRef imageRef = CGImageCreate( width, height, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpaceRef, bitmapInfo, provider, NULL, NO, kCGRenderingIntentDefault );
    return imageRef;
}

- (void) printFace:(CIFaceFeature*) face imageHeight:(uint32_t)imageHeight {
    [FaceDetection log:@"-- FaceFeature"];
    [FaceDetection log:[NSString stringWithFormat:@"hasSmile: %d", face.hasSmile]];
    [FaceDetection log:[NSString stringWithFormat:@"left Eye closed: %d", face.leftEyeClosed]];
    [FaceDetection log:[NSString stringWithFormat:@"right Eye closed: %d", face.rightEyeClosed]];
    [FaceDetection log:[NSString stringWithFormat:@"Face pos: %g at %g | %g x %g", face.bounds.origin.x, face.bounds.origin.y, face.bounds.size.width, face.bounds.size.height]];
    if( face.hasLeftEyePosition ) {
        [FaceDetection log:[NSString stringWithFormat:@"has Left Eye pos: %g at %g", face.leftEyePosition.x, (imageHeight - face.leftEyePosition.y)]];
    }
    if( face.hasRightEyePosition ) {
        [FaceDetection log:[NSString stringWithFormat:@"has Right Eye pos: %g at %g", face.rightEyePosition.x, (imageHeight - face.rightEyePosition.y)]];
    }
    if( face.hasMouthPosition ) {
        [FaceDetection log:[NSString stringWithFormat:@"has Mouth pos: %g at %g", face.mouthPosition.x, (imageHeight - face.mouthPosition.y)]];
    }
    [FaceDetection log:@""];
}

@end
