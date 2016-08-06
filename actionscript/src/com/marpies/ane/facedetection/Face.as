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
        private var mRightEyePosition:Point;
        private var mMouthPosition:Point;
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
            face.mLeftEyePosition = new Point( json.leftEyeX, json.leftEyeY );
            face.mRightEyePosition = new Point( json.rightEyeX, json.rightEyeY );
            face.mMouthPosition = new Point( json.mouthX, json.mouthY );
            face.mBounds = new Rectangle( json.faceX, json.faceY, json.faceWidth, json.faceHeight );
            return face;
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

    }

}
