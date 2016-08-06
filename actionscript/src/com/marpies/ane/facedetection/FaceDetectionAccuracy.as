package com.marpies.ane.facedetection {

    /**
     * Constants used to specify detection accuracy.
     */
    public class FaceDetectionAccuracy {

        /**
         * Low accuracy detection settings. This will tend to detect fewer faces
         * and may be less precise in determining values such as position, but will run faster.
         */
        public static const LOW:int = 0;
        /**
         * High accuracy detection settings. This will tend to detect more faces
         * and may be more precise in determining values such as position, at the cost of speed.
         */
        public static const HIGH:int = 1;

    }

}
