package com.marpies.ane.facedetection {

    import flash.geom.Point;
    import flash.geom.Rectangle;

    /**
     * Object representing detected face.
     */
    public class Face {

        /**
         * The value that a probability is set to if it was not computed.
         */
        public static const UNCOMPUTED_PROBABILITY:Number = -1.0;

        private var mLeftEyeOpenProbability:Number = 0;
        private var mRightEyeOpenProbability:Number = 0;
        private var mIsSmilingProbability:Number = 0;

        private var mLeftEyePosition:Point;
        private var mLeftMouthPosition:Point;
        private var mLeftEarPosition:Point;
        private var mLeftEarTipPosition:Point;
        private var mLeftCheekPosition:Point;
        private var mRightEyePosition:Point;
        private var mRightMouthPosition:Point;
        private var mRightEarPosition:Point;
        private var mRightEarTipPosition:Point;
        private var mRightCheekPosition:Point;
        private var mMouthPosition:Point;
        private var mNoseBasePosition:Point;
        private var mBounds:Rectangle;

        /**
         * @private
         */
        public function Face() {
        }

        /**
         * @private
         */
        internal static function fromJSON( json:Object ):Face {
            var face:Face = new Face();
            face.mLeftEyeOpenProbability = json.leftEyeOpenProbability;
            face.mRightEyeOpenProbability = json.rightEyeOpenProbability;
            face.mIsSmilingProbability = json.isSmilingProbability;
            face.mLeftEyePosition = getLandmarkPosition( "leftEye", json );
            face.mRightEyePosition = getLandmarkPosition( "rightEye", json );
            face.mMouthPosition = getLandmarkPosition( "mouth", json );
            face.mLeftMouthPosition = getLandmarkPosition( "leftMouth", json );
            face.mLeftEarPosition = getLandmarkPosition( "leftEar", json );
            face.mLeftEarTipPosition = getLandmarkPosition( "leftEarTip", json );
            face.mLeftCheekPosition = getLandmarkPosition( "leftCheek", json );
            face.mRightMouthPosition = getLandmarkPosition( "rightMouth", json );
            face.mRightEarPosition = getLandmarkPosition( "rightEar", json );
            face.mRightEarTipPosition = getLandmarkPosition( "rightEarTip", json );
            face.mRightCheekPosition = getLandmarkPosition( "rightCheek", json );
            face.mNoseBasePosition = getLandmarkPosition( "noseBase", json );
            face.mBounds = new Rectangle( json.faceX, json.faceY, json.faceWidth, json.faceHeight );
            return face;
        }

        /**
         * @private
         */
        private static function getLandmarkPosition( landmark:String, json:Object ):Point {
            var landmarkKeyX:String = landmark + "X";
            if( landmarkKeyX in json ) {
                var landmarkKeyY:String = landmark + "Y";
                return new Point( json[landmarkKeyX], json[landmarkKeyY] );
            }
            return null;
        }

        /**
         * Rectangle representing the face's position and size.
         */
        public function get bounds():Rectangle {
            return mBounds;
        }

        /**
         * Position of the mouth in the image.
         */
        public function get mouthPosition():Point {
            return mMouthPosition;
        }

        /**
         * Position of the left eye. The left eye is relative to the subject,
         * it is not the eye that is on the left when viewing the image.
         */
        public function get leftEyePosition():Point {
            return mLeftEyePosition;
        }

        /**
         * Position of the right eye. The right eye is relative to the subject,
         * it is not the eye that is on the right when viewing the image.
         */
        public function get rightEyePosition():Point {
            return mRightEyePosition;
        }

        /**
         * Returns a value between 0.0 and 1.0 giving a probability that the face is smiling,
         * or -1.0 if the value was not computed.
         *
         * @see #UNCOMPUTED_PROBABILITY
         */
        public function get isSmilingProbability():Number {
            return mIsSmilingProbability;
        }

        /**
         * Returns a value between 0.0 and 1.0 giving a probability that the face's left eye is open,
         * or -1.0 if the value was not computed.
         *
         * @see #UNCOMPUTED_PROBABILITY
         */
        public function get leftEyeOpenProbability():Number {
            return mLeftEyeOpenProbability;
        }

        /**
         * Returns a value between 0.0 and 1.0 giving a probability that the face's right eye is open,
         * or -1.0 if the value was not computed.
         *
         * @see #UNCOMPUTED_PROBABILITY
         */
        public function get rightEyeOpenProbability():Number {
            return mRightEyeOpenProbability;
        }

        /**
         * <strong>Android only:</strong> - Returns subject's left mouth corner where the lips meet,
         * or <code>null</code> if not available.
         */
        public function get leftMouthPosition():Point {
            return mLeftMouthPosition;
        }

        /**
         * <strong>Android only:</strong> - Returns midpoint of the subject's left ear tip and left ear lobe,
         * or <code>null</code> if not available.
         */
        public function get leftEarPosition():Point {
            return mLeftEarPosition;
        }

        /**
         * <strong>Android only:</strong> - Treating the top of the subject's left ear as a circle, this is the point
         * at 45 degrees around the circle in Cartesian coordinates, or <code>null</code> if not available.
         */
        public function get leftEarTipPosition():Point {
            return mLeftEarTipPosition;
        }

        /**
         * <strong>Android only:</strong> - Returns midpoint between the subject's left mouth corner and the outer
         * corner of the subject's left eye, or <code>null</code> if not available.
         */
        public function get leftCheekPosition():Point {
            return mLeftCheekPosition;
        }

        /**
         * <strong>Android only:</strong> - Returns subject's right mouth corner where the lips meet,
         * or <code>null</code> if not available.
         */
        public function get rightMouthPosition():Point {
            return mRightMouthPosition;
        }

        /**
         * <strong>Android only:</strong> - Returns midpoint of the subject's right ear tip and right ear lobe,
         * or <code>null</code> if not available.
         */
        public function get rightEarPosition():Point {
            return mRightEarPosition;
        }

        /**
         * <strong>Android only:</strong> - Treating the top of the subject's right ear as a circle, this is the point
         * at 135 degrees around the circle in Cartesian coordinates, or <code>null</code> if not available.
         */
        public function get rightEarTipPosition():Point {
            return mRightEarTipPosition;
        }

        /**
         * <strong>Android only:</strong> - Returns midpoint between the subject's right mouth corner and the outer
         * corner of the subject's right eye, or <code>null</code> if not available.
         */
        public function get rightCheekPosition():Point {
            return mRightCheekPosition;
        }

        /**
         * <strong>Android only:</strong> - Returns midpoint between the subject's nostrils where the nose meets the
         * face, or <code>null</code> if not available.
         */
        public function get noseBasePosition():Point {
            return mNoseBasePosition;
        }

    }

}
