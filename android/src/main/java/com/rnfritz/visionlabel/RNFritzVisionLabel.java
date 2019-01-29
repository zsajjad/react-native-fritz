package com.rnfritz.visionlabel;

import android.graphics.Bitmap;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.rnfritz.Utils;

import ai.fritz.vision.inputs.FritzVisionImage;
import ai.fritz.visionlabel.FritzVisionLabelPredictor;
import ai.fritz.visionlabel.FritzVisionLabelPredictorOptions;
import ai.fritz.visionlabel.FritzVisionLabelResult;

public class RNFritzVisionLabel extends ReactContextBaseJavaModule {

    private static final float CONFIDENCE_THRESHOLD = 0.7f;
    public RNFritzVisionLabel(ReactApplicationContext reactContext) {
        super(reactContext);
//        mReactContext = reactContext;
//        initFritz();
    }
    @ReactMethod
    public void predict(final String imageURI, final Promise promise){
        try{
            // Create predictor options
            FritzVisionLabelPredictorOptions options = new FritzVisionLabelPredictorOptions
                    .Builder()
                    .confidenceThreshold(CONFIDENCE_THRESHOLD)
                    .build();

            final FritzVisionLabelPredictor visionPredictor = new FritzVisionLabelPredictor(options);

            Bitmap img = Utils.getBitmapFromURL(imageURI);

            if(img != null){

                FritzVisionImage visionImage = FritzVisionImage.fromBitmap(img);

                FritzVisionLabelResult labelResult = visionPredictor.predict(visionImage);

                Response output = new Response();

                output.setVisionLabels(labelResult.getVisionLabels());

                promise.resolve(output.getOutput());
            }
            else{
                throw new Exception("Image Not Found");
            }

        }
        catch(Exception error){
            promise.reject(error);
        }

    }

    @Override
    public String getName() {
        return "RNFritzVisionLabel";
    }
}
