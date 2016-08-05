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
#import "Functions/DetectFacesFunction.h"
#import "Functions/SetLogEnabledFunction.h"

static BOOL FaceDetectionLogEnabled = NO;
FREContext FaceDetectionExtContext = nil;

@implementation FaceDetection

+ (void) dispatchEvent:(const NSString*) eventName {
    [self dispatchEvent:eventName withMessage:@""];
}

+ (void) dispatchEvent:(const NSString*) eventName withMessage:(NSString*) message {
    NSString* messageText = message ? message : @"";
    FREDispatchStatusEventAsync( FaceDetectionExtContext, (const uint8_t*) [eventName UTF8String], (const uint8_t*) [messageText UTF8String] );
}

+ (void) log:(const NSString*) message {
    if( FaceDetectionLogEnabled ) {
        NSLog( @"[iOS-FaceDetection] %@", message );
    }
}

+ (void) showLogs:(BOOL) showLogs {
    FaceDetectionLogEnabled = showLogs;
}

+ (BOOL) isLogEnabled {
    return FaceDetectionLogEnabled;
}

@end

/**
 *
 *
 * Context initialization
 *
 *
 **/

FRENamedFunction FaceDetection_extFunctions[] = {
    { (const uint8_t*) "detect",        0, fd_detectFaces },
    { (const uint8_t*) "setLogEnabled", 0, fd_setLogEnabled }
};

void FaceDetectionContextInitializer( void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctionsToSet, const FRENamedFunction** functionsToSet ) {
    *numFunctionsToSet = sizeof( FaceDetection_extFunctions ) / sizeof( FRENamedFunction );
    
    *functionsToSet = FaceDetection_extFunctions;
    
    FaceDetectionExtContext = ctx;
}

void FaceDetectionContextFinalizer( FREContext ctx ) { }

void FaceDetectionInitializer( void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet ) {
    *extDataToSet = NULL;
    *ctxInitializerToSet = &FaceDetectionContextInitializer;
    *ctxFinalizerToSet = &FaceDetectionContextFinalizer;
}

void FaceDetectionFinalizer( void* extData ) { }







