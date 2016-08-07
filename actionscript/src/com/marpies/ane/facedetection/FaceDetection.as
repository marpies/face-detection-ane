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

package com.marpies.ane.facedetection {

    import flash.display.BitmapData;
    import flash.events.StatusEvent;
    import flash.external.ExtensionContext;
    import flash.system.Capabilities;
    import flash.utils.Dictionary;

    /**
     * Class providing APIs for face detection.
     */
    public class FaceDetection {

        private static const TAG:String = "[FaceDetection]";
        private static const EXTENSION_ID:String = "com.marpies.ane.facedetection";
        private static const iOS:Boolean = Capabilities.manufacturer.indexOf( "iOS" ) > -1;
        private static const ANDROID:Boolean = Capabilities.manufacturer.indexOf( "Android" ) > -1;

        private static var mContext:ExtensionContext;

        /* Event codes */
        private static const FACE_DETECTION_COMPLETE:String = "faceDetectionComplete";
        private static const FACE_DETECTION_ERROR:String = "faceDetectionError";

        /* Callbacks */
        private static var mCallbackMap:Dictionary;
        private static var mCallbackIdCounter:int;

        /* Misc */
        private static var mLogEnabled:Boolean;

        /**
         * @private
         * Do not use. FaceDetection is a static class.
         */
        public function FaceDetection() {
            throw Error( "FaceDetection is static class." );
        }

        /**
         *
         *
         * Public API
         *
         *
         */

        /**
         * Detects faces in the provided image.
         * 
         * @param imageData <code>BitmapData</code> of the image to detect faces on.
         * @param callback Function with the following signature:
         * <listing version="3.0">
         * function callback( faces:Vector.&lt;Face&gt;, errorMessage:String ):void {
         *
         * };
         * </listing>
         *
         * @param options Options for the detector. If not provided, default values are used.
         *
         * @see com.marpies.ane.facedetection.FaceDetectionOptions
         */
        public static function detect( imageData:BitmapData, callback:Function, options:FaceDetectionOptions = null ):void {
            if( !isSupported ) return;

            if( imageData === null ) throw new ArgumentError( "Parameter imageData cannot be null." );
            if( callback === null ) throw new ArgumentError( "Parameter callback cannot be null." );
            /* Use default options if not specified */
            if( options === null ) {
                options = new FaceDetectionOptions();
            }
            if( !options.isValid ) throw new Error( "Detection accuracy must be set to one of the values defined in FaceDetectionAccuracy class." );

            /* Initialize context */
            if( !initExtensionContext() ) {
                log( "Error creating extension context for " + EXTENSION_ID );
                return;
            }
            /* Listen for native library events */
            if( !mContext.hasEventListener( StatusEvent.STATUS ) ) {
                mContext.addEventListener( StatusEvent.STATUS, onStatus );
            }

            if( mCallbackMap === null ) {
                mCallbackMap = new Dictionary();
            }

            /* Call init */
            mContext.call( "detect", imageData, registerCallback( callback ), options.accuracy, options.detectOpenEyes, options.detectSmile, options.prominentFaceOnly );
        }

        /**
         * Pass in <code>true</code> to show extension log messages.
         */
        public static function setLogEnabled( value:Boolean ):void {
            if( !isSupported ) return;
            if( !initExtensionContext() ) return;

            mLogEnabled = value;

            mContext.call( "setLogEnabled", value );
        }

        /**
         * Disposes native extension context.
         */
        public static function dispose():void {
            if( !isSupported ) return;
            validateExtensionContext();

            mContext.removeEventListener( StatusEvent.STATUS, onStatus );
            mContext.dispose();
            mContext = null;
        }

        /**
         *
         *
         * Getters / Setters
         *
         *
         */

        /**
         * Checks whether <em>Google Play Services</em> APK is installed on the device.
         * It is necessary for the detector to function properly.
         *
         * <p>On iOS, it is always <code>true</code></p>
         */
        public static function get isAvailable():Boolean {
            if( !isSupported ) return false;
            if( !initExtensionContext() ) return false;

            return mContext.call( "isAvailable" ) as Boolean;
        }

        /**
         * Checks whether the internal detector is operational.
         *
         * <p>On Android, it checks whether necessary libraries have been downloaded,
         * which means the detection may not work shortly after launching an app
         * for the very first time.</p>
         *
         * <p>Unfortunately, there is not callback to find out when the libraries are
         * ready, so <em>'try again later</em> approach must be used.</p>
         *
         * <p>On iOS, it is always <code>true</code></p>
         */
        public static function get isOperational():Boolean {
            if( !isSupported ) return false;
            if( !initExtensionContext() ) return false;

            return mContext.call( "isOperational" ) as Boolean;
        }

        /**
         * Extension version.
         */
        public static function get version():String {
            return "1.0.0";
        }

        /**
         * Supported on iOS and Android.
         */
        public static function get isSupported():Boolean {
            return iOS || ANDROID;
        }

        /**
         *
         *
         * Private API
         *
         *
         */

        private static function onStatus( event:StatusEvent ):void {
            var json:Object = null;
            var callback:Function = null;
            var callbackId:int = -1;
            switch( event.code ) {
                case FACE_DETECTION_ERROR:
                    json = JSON.parse( event.level );
                    var errorMessage:String = json.errorMessage;
                    callbackId = json.listenerID;
                    callback = getCallback( callbackId );
                    if( callback !== null ) {
                        unregisterCallback( callbackId );
                        callback( null, errorMessage );
                    }
                    return;
                case FACE_DETECTION_COMPLETE:
                    json = JSON.parse( event.level );
                    if( "callbackId" in json ) {
                        callbackId = json.callbackId;
                        var faces:Vector.<Face> = getFacesFromJSON( json.faces );
                        callback = getCallback( callbackId );
                        if( callback !== null ) {
                            unregisterCallback( callbackId );
                            callback( faces, null );
                        }
                    }
                    return;
            }
        }

        private static function getFacesFromJSON( faces:Object ):Vector.<Face> {
            if( faces === null ) return null;
            if( faces is String ) {
                faces = JSON.parse( faces as String );
            }
            var facesArray:Array = faces as Array;
            var result:Vector.<Face> = new <Face>[];
            var length:int = facesArray.length;
            for( var i:int = 0; i < length; ++i ) {
                var faceJSON:Object = facesArray[i];
                if( faceJSON is String ) {
                    faceJSON = JSON.parse( faceJSON as String );
                }
                result[i] = Face.fromJSON( faceJSON );
            }
            return result;
        }

        /**
         * Initializes extension context.
         * @return <code>true</code> if initialized successfully, <code>false</code> otherwise.
         */
        private static function initExtensionContext():Boolean {
            if( mContext === null ) {
                mContext = ExtensionContext.createExtensionContext( EXTENSION_ID, null );
            }
            return mContext !== null;
        }

        private static function validateExtensionContext():void {
            if( !mContext ) throw new Error( "FaceDetection extension was not initialized. Call init() first." );
        }

        /**
         * Registers given callback and generates ID which is used to look the callback up when it is time to call it.
         * @param callback Function to register.
         * @return ID of the callback.
         */
        private static function registerCallback( callback:Function ):int {
            if( callback == null ) return -1;

            mCallbackMap[mCallbackIdCounter] = callback;
            return mCallbackIdCounter++;
        }

        /**
         * Gets registered callback with given ID.
         * @param callbackID ID of the callback to retrieve.
         * @return Callback registered with given ID, or <code>null</code> if no such callback exists.
         */
        private static function getCallback( callbackID:int ):Function {
            if( callbackID == -1 || !(callbackID in mCallbackMap) ) return null;
            return mCallbackMap[callbackID];
        }

        /**
         * Unregisters callback with given ID.
         * @param callbackID ID of the callback to unregister.
         */
        private static function unregisterCallback( callbackID:int ):void {
            if( callbackID in mCallbackMap ) {
                delete mCallbackMap[callbackID];
            }
        }

        private static function log( message:String ):void {
            if( mLogEnabled ) {
                trace( TAG, message );
            }
        }

    }
}
