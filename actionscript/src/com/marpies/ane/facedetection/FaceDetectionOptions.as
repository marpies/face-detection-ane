package com.marpies.ane.facedetection {

    /**
     * Object allowing to specify several face detection options.
     */
    public class FaceDetectionOptions {

        private var mAccuracy:int;
        private var mDetectOpenEyes:Boolean;
        private var mDetectSmile:Boolean;
        private var mProminentFaceOnly:Boolean;

        /**
         * @private
         */
        public function FaceDetectionOptions() {
            mAccuracy = FaceDetectionAccuracy.HIGH;
        }

        /**
         * Face detection accuracy. High accuracy will generally result in longer runtime.
         * Lower accuracy will generally result in detecting fewer faces.
         *
         * @default FaceDetectionAccuracy.HIGH
         *
         * @see com.marpies.ane.facedetection.FaceDetectionAccuracy
         */
        public function get accuracy():int {
            return mAccuracy;
        }

        /**
         * @private
         */
        public function set accuracy( value:int ):void {
            mAccuracy = value;
        }

        /**
         * Set to <code>true</code> to enable detection of open eyes.
         *
         * @default false
         */
        public function get detectOpenEyes():Boolean {
            return mDetectOpenEyes;
        }

        /**
         * @private
         */
        public function set detectOpenEyes( value:Boolean ):void {
            mDetectOpenEyes = value;
        }

        /**
         * Set to <code>true</code> to enable detection of smile.
         *
         * @default false
         */
        public function get detectSmile():Boolean {
            return mDetectSmile;
        }

        /**
         * @private
         */
        public function set detectSmile( value:Boolean ):void {
            mDetectSmile = value;
        }

        /**
         * <strong>Android only</strong> - Indicates whether to detect all faces, or to only detect the most prominent
         * face (i.e., a large face that is most central within the frame). By default, there is no limit in the number
         * of faces detected. Setting this value to <code>true</code> can increase the speed of the detector since the
         * detector does not need to search exhaustively for all faces.
         *
         * @default false
         */
        public function get prominentFaceOnly():Boolean {
            return mProminentFaceOnly;
        }

        /**
         * @private
         */
        public function set prominentFaceOnly( value:Boolean ):void {
            mProminentFaceOnly = value;
        }

        /**
         * @private
         */
        internal function get isValid():Boolean {
            return (mAccuracy == FaceDetectionAccuracy.HIGH) || (mAccuracy == FaceDetectionAccuracy.LOW);
        }

    }

}
