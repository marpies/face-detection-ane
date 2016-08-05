package com.marpies.ane.facedetection {

    import flash.geom.Point;
    import flash.geom.Rectangle;

    public class Face {

        private var mLeftEyeOpenProbability:Number;
        private var mRightEyeOpenProbability:Number;
        private var mIsSmilingProbability:Number;

        private var mLeftEyePosition:Point;
        private var mRightEyePosition:Point;
        private var mMouthPosition:Point;
        private var mBounds:Rectangle;

        public function Face() {
        }

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

        public function get bounds():Rectangle {
            return mBounds;
        }

        public function get mouthPosition():Point {
            return mMouthPosition;
        }

        public function get leftEyePosition():Point {
            return mLeftEyePosition;
        }

        public function get rightEyePosition():Point {
            return mRightEyePosition;
        }

        public function get isSmilingProbability():Number {
            return mIsSmilingProbability;
        }

        public function get leftEyeOpenProbability():Number {
            return mLeftEyeOpenProbability;
        }

        public function get rightEyeOpenProbability():Number {
            return mRightEyeOpenProbability;
        }
    }

}
