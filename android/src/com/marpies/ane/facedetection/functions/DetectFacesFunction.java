/**
 * Copyright 2016 Marcel Piestansky (http://marpies.com)
 * <p>
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * <p>
 * http://www.apache.org/licenses/LICENSE-2.0
 * <p>
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.marpies.ane.facedetection.functions;

import android.app.Activity;
import android.graphics.Bitmap;
import android.util.SparseArray;
import com.adobe.fre.FREBitmapData;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREObject;
import com.google.android.gms.vision.Detector;
import com.google.android.gms.vision.Frame;
import com.google.android.gms.vision.face.Face;
import com.google.android.gms.vision.face.FaceDetector;
import com.google.android.gms.vision.face.Landmark;
import com.marpies.ane.facedetection.data.FaceDetectionEvent;
import com.marpies.ane.facedetection.utils.*;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.List;

public class DetectFacesFunction extends BaseFunction {

	@Override
	public FREObject call( FREContext context, FREObject[] args ) {
		super.call( context, args );

		AIR.log( "FaceDetection::detect" );

		final int callbackId = FREObjectUtils.getInt( args[1] );
		final Bitmap image;
		try {
			image = BitmapDataUtils.getBitmap( (FREBitmapData) args[0] );
		} catch( Exception e ) {
			e.printStackTrace();
			AIR.log( "Error creating Bitmap out of FREBitmapData" );
			AIR.dispatchEvent(
					FaceDetectionEvent.FACE_DETECTION_ERROR,
					StringUtils.getEventErrorJSON( callbackId, "Error creating Bitmap out of FREBitmapData" )
			);
			return null;
		}
		/* Mode (accuracy) */
		final int accuracy = FREObjectUtils.getInt( args[2] ); // Comes in as a ready-to-use value
		boolean detectOpenEyes = FREObjectUtils.getBoolean( args[3] );
		boolean detectSmile = FREObjectUtils.getBoolean( args[4] );
		final boolean prominentFaceOnly = FREObjectUtils.getBoolean( args[5] );
		/* Classification type (detect open eyes, detect smile) */
		final int classification = (detectOpenEyes || detectSmile) ? FaceDetector.ALL_CLASSIFICATIONS : FaceDetector.NO_CLASSIFICATIONS;

		final Activity activity = AIR.getContext().getActivity();

		new Thread(
				new Runnable() {
					@Override
					public void run() {
						AIR.log( "Running FaceDetection in new thread" );
						FaceDetector.Builder fb = new FaceDetector.Builder( activity.getApplicationContext() );
						fb.setClassificationType( classification )
								.setMode( accuracy )
								.setTrackingEnabled( false )
								.setLandmarkType( FaceDetector.ALL_LANDMARKS ) // We want to know about eye/mouth positions
								.setProminentFaceOnly( prominentFaceOnly );

						/* Wrap the detector in SafeFaceDetector */
						final FaceDetector detector = fb.build();
						Detector<Face> sd = new SafeFaceDetector( detector );
						if( !sd.isOperational() ) {
							sd.release();
							AIR.log( "Error, detector is not operational." );
							AIR.dispatchEvent( FaceDetectionEvent.FACE_DETECTION_ERROR, "Detector is not operational. Dependencies may have not been downloaded yet. Please, try again later." );
							return;
						}

						/* Create Frame with bitmap */
						final Frame frame = new Frame.Builder().setBitmap( image ).build();
						SparseArray<Face> faces = sd.detect( frame );

						/* Build faces JSONArray */
						JSONArray facesResult = getFacesJSONArray( faces );
						dispatchResponse( facesResult, callbackId );

						sd.release();
					}
				}
		).start();

		return null;
	}

	private JSONArray getFacesJSONArray( SparseArray<Face> faces ) {
		int numFaces = faces.size();
		JSONArray facesResult = new JSONArray();
		for( int i = 0; i < numFaces; i++ ) {
			Face face = faces.valueAt( i );
			String faceJSON = getFaceJSON( face );
			if( faceJSON != null ) {
				facesResult.put( faceJSON );
			} else {
				AIR.log( "Error making JSON out of Face object" );
			}
		}
		AIR.log( "Parsed " + facesResult.length() + " faces" );
		return facesResult;
	}

	private void dispatchResponse( JSONArray facesResult, int callbackId ) {
		JSONObject response = new JSONObject();
		try {
			response.put( "faces", facesResult.toString() );
			response.put( "callbackId", callbackId );
			AIR.dispatchEvent( FaceDetectionEvent.FACE_DETECTION_COMPLETE, response.toString() );
		} catch( JSONException e ) {
			e.printStackTrace();
			AIR.log( "Error creating JSON response" );
			AIR.dispatchEvent(
					FaceDetectionEvent.FACE_DETECTION_ERROR,
					StringUtils.getEventErrorJSON( callbackId, "Error creating JSON response" )
			);
		}
	}

	private String getFaceJSON( Face face ) {
		JSONObject json = new JSONObject();
		try {
			json.put( "faceX", face.getPosition().x );
			json.put( "faceY", face.getPosition().y );
			json.put( "faceWidth", face.getWidth() );
			json.put( "faceHeight", face.getHeight() );
			json.put( "leftEyeOpenProbability", face.getIsLeftEyeOpenProbability() );
			json.put( "rightEyeOpenProbability", face.getIsRightEyeOpenProbability() );
			json.put( "isSmilingProbability", face.getIsSmilingProbability() );
			List<Landmark> landmarks = face.getLandmarks();
			for( Landmark landmark : landmarks ) {
				addLandmark( landmark, json );
			}
		} catch( JSONException e ) {
			e.printStackTrace();
			return null;
		}
		return json.toString();
	}

	private void addLandmark( Landmark landmark, JSONObject json ) throws JSONException {
		/* Mouth position */
		int landmarkType = landmark.getType();
		String landmarkKey = getLandmarkKey( landmarkType );
		if( landmarkKey != null ) {
			json.put( landmarkKey + "X", landmark.getPosition().x );
			json.put( landmarkKey + "Y", landmark.getPosition().y );
		}
	}

	private String getLandmarkKey( int landmarkType ) {
		switch( landmarkType ) {
			case Landmark.BOTTOM_MOUTH: return "mouth";
			case Landmark.LEFT_EYE: return "leftEye";
			case Landmark.RIGHT_EYE: return "rightEye";
			case Landmark.LEFT_EAR: return "leftEar";
			case Landmark.LEFT_EAR_TIP: return "leftEarTip";
			case Landmark.LEFT_CHEEK: return "leftCheek";
			case Landmark.LEFT_MOUTH: return "leftMouth";
			case Landmark.RIGHT_EAR: return "rightEar";
			case Landmark.RIGHT_EAR_TIP: return "rightEarTip";
			case Landmark.RIGHT_CHEEK: return "rightCheek";
			case Landmark.RIGHT_MOUTH: return "rightMouth";
			case Landmark.NOSE_BASE: return "noseBase";
			default: return null;
		}
	}

}
