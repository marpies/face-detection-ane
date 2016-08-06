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

package com.marpies.ane.facedetection.utils;

import android.graphics.*;
import com.adobe.fre.FREBitmapData;
import com.adobe.fre.FREInvalidObjectException;
import com.adobe.fre.FREWrongThreadException;

public class BitmapDataUtils {

	private static final float[] mBGRToRGBColorTransform =
			{
					0, 0, 1f, 0, 0,
					0, 1f, 0, 0, 0,
					1f, 0, 0, 0, 0,
					0, 0, 0, 1f, 0
			};
	private static final ColorMatrixColorFilter mColorFilter = new ColorMatrixColorFilter(
			new ColorMatrix( mBGRToRGBColorTransform )
	);

	/**
	 * Switch color channels
	 * http://stackoverflow.com/questions/17314467/bitmap-channels-order-different-in-android
	 */
	public static Bitmap getBitmap( FREBitmapData bitmapData ) throws FREWrongThreadException, FREInvalidObjectException {
		bitmapData.acquire();
		Bitmap bitmap = Bitmap.createBitmap( bitmapData.getWidth(), bitmapData.getHeight(), Bitmap.Config.ARGB_8888 );
		Canvas canvas = new Canvas( bitmap );
		Paint paint = new Paint();
		paint.setColorFilter( mColorFilter );
		bitmap.copyPixelsFromBuffer( bitmapData.getBits() );
		bitmapData.release();
		canvas.drawBitmap( bitmap, 0, 0, paint );
		return bitmap;
	}

}
