package com.rnfritz.ImageLabeling;

import android.graphics.Bitmap;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.rnfritz.Utils;

import ai.fritz.vision.inputs.FritzVisionImage;
import ai.fritz.visionlabel.FritzVisionLabelPredictor;
import ai.fritz.visionlabel.FritzVisionLabelPredictorOptions;
import ai.fritz.visionlabel.FritzVisionLabelResult;

public class RNFritzVisionImageLabeling extends ReactContextBaseJavaModule {

    private float CONFIDENCE_THRESHOLD = 0.7f;

    public RNFritzVisionImageLabeling(ReactApplicationContext reactContext) {
        super(reactContext);
    }

    @ReactMethod
    public void predictFromImage(final ReadableMap params, final Promise promise){
        try{
            String imageURI = params.hasKey("imagePath") ? params.getString("imagePath") : null;
            CONFIDENCE_THRESHOLD = params.hasKey("threshold") ? (float) params.getDouble("threshold") : CONFIDENCE_THRESHOLD;


            if(imageURI == null){
                promise.reject("Missing params", "Missing parameters");
                return;
            }
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
        return "RNFritzVisionImageLabeling";
    }
}
