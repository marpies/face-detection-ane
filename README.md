# Face Detection | Native extension for Adobe AIR (iOS & Android)

#### Native extension providing ActionScript interface for [Google's Mobile Vision](https://developers.google.com/vision/) and [Apple's CoreImage](https://developer.apple.com/library/ios/documentation/CoreImage/Reference/CIDetector_Ref/index.html#//apple_ref/occ/cl/CIDetector) face detector APIs.

Development of this extension is supported by [Master Tigra, Inc.](https://github.com/mastertigra)

## Getting started

### Additions to AIR descriptor

First, add the extension's ID to the `extensions` element.

```xml
<extensions>
    <extensionID>com.marpies.ane.facedetection</extensionID>
</extensions>
```

If you are targeting Android, add the following extensions from [this repository](https://github.com/marpies/android-dependency-anes) as well (unless you know these libraries are included by some other extensions):

```xml
<extensions>
    <extensionID>com.marpies.ane.androidsupport</extensionID>
    <extensionID>com.marpies.ane.googleplayservices.base</extensionID>
    <extensionID>com.marpies.ane.googleplayservices.basement</extensionID>
    <extensionID>com.marpies.ane.googleplayservices.tasks</extensionID>
    <extensionID>com.marpies.ane.googleplayservices.vision</extensionID>
</extensions>
```

For Android support, modify `manifestAdditions` element so that it contains the following permission and meta data:

```xml
<android>
    <manifestAdditions>
        <![CDATA[
        <manifest android:installLocation="auto">
            <uses-permission android:name="android.permission.INTERNET"/>

            <application>

                <meta-data android:name="com.google.android.gms.version" android:value="@integer/google_play_services_version" />
                <meta-data android:name="com.google.android.gms.vision.DEPENDENCIES" android:value="face" />

            </application>

        </manifest>
        ]]>
    </manifestAdditions>

</android>
```

> Adding the vision functionality dependency to your app's manifest will indicate to the installer that it should download the dependency on app install time. Although this is not strictly required, it can make the user experience better when initially running your app.

> However, even if this is supplied, in some cases the dependencies required to run the detectors may be downloaded on demand when your app is run for the first time rather than at install time.

Finally, add the [FaceDetection ANE](bin/com.marpies.ane.facedetection.ane) or [SWC](bin/com.marpies.ane.facedetection.swc) package from the [bin directory](bin/) to your project so that your IDE can work with it. The additional Android library ANEs are only necessary during packaging.

### API overview

#### Debug logs

You can enable extension debug logs during development using:

```as3
FaceDetection.setLogEnabled( true );
```

#### Detection

When detecting faces in an image, you can provide [FaceDetectionOptions](actionscript/src/com/marpies/ane/facedetection/FaceDetectionOptions.as) object with the following properties:

```as3
var options:FaceDetectionOptions = new FaceDetectionOptions();
// Face detection accuracy (high vs low)
options.accuracy = FaceDetectionAccuracy.HIGH;
// Set to true to enable detection of open eyes
options.detectOpenEyes = true;
// Set to true to enable detection of smile
options.detectSmile = true;
// (Android only) Indicates whether to detect all faces, or to only detect the most prominent face
options.prominentFaceOnly = true;
```

To run the detection, call the [detect](actionscript/src/com/marpies/ane/facedetection/FaceDetection.as#L79-L106) method by passing in `BitmapData` of the image you want to process, a callback method and, optionally, the options object:

```as3
FaceDetection.detect( bitmapData, onDetectionComplete, options );
```

The detection process is asynchronous; the callback method is called once the process is finished successfully or with an error. The callback is expected to accept list of detected faces and a `String` that specifies an error message, in cases when a problem occurs.

```as3
function onDetectionComplete( faces:Vector.<Face>, errorMessage:String ):void {
    if( errorMessage == null ) {
        // process faces
    } else {
        // there was an error
    }
}
```

#### Face object

The [Face](actionscript/src/com/marpies/ane/facedetection/Face.as) object provides the following properties:

```as3
// Rectangle representing the face's position and size
face.bounds : Rectangle
// Returns a value between 0.0 and 1.0 giving a probability that the face is smiling / has left/right eye open,
// or -1.0 if the value was not computed. On iOS, these values are always either 0 or 1
face.isSmilingProbability : Number
face.leftEyeOpenProbability : Number
face.rightEyeOpenProbability : Number
// Position of the mouth in the image
face.mouthPosition : Point
// Eye positions - these are relative to the subject (person), i.e. left eye is the subject's left eye,
// not the eye that is on the left when viewing the image
face.leftEyePosition : Point
face.rightEyePosition : Point
```

#### isOperational : Boolean

Checks whether the internal detector is operational. On Android, it checks whether necessary libraries have been downloaded, which means the detection may not work shortly after launching an app for the very first time. Unfortunately, there is no callback to find out when the libraries are ready, so *try again later* approach must be used. On iOS, it is always `true`.

#### isAvailable : Boolean

Checks whether *Google Play Services* APK is installed on the device. It is necessary for the detector to function properly. On iOS, it is always `true`.

## Requirements

* iOS 7+
* Android 4+
* Adobe AIR 20+

## Documentation
Generated ActionScript documentation is available in the [docs](docs/) directory, or can be generated by running `ant asdoc` from the [build](build/) directory.

## Build ANE
ANT build scripts are available in the [build](build/) directory. Edit [build.properties](build/build.properties) to correspond with your local setup.

## Author
The ANE has been written by [Marcel Piestansky](https://twitter.com/marpies) and is distributed under [Apache License, version 2.0](http://www.apache.org/licenses/LICENSE-2.0.html).

## Changelog

#### August 10, 2016 (v1.0.1)

* REMOVED `flash.external.ExtensionContext` dependency from SWC and SWF targeting default platform

#### August 7, 2016 (v1.0.0)

* Public release
