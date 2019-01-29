package com.rnfritz.visionobject;

import android.graphics.Bitmap;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.rnfritz.Utils;

import ai.fritz.fritzvisionobjectmodel.FritzVisionObjectPredictor;
import ai.fritz.fritzvisionobjectmodel.FritzVisionObjectPredictorOptions;
import ai.fritz.fritzvisionobjectmodel.FritzVisionObjectResult;
import ai.fritz.vision.inputs.FritzVisionImage;

public class RNFritzVisionObject extends ReactContextBaseJavaModule {
    private static final float CONFIDENCE_THRESHOLD = 0.7f;
    private static final int MAX_OBJECT = 10;

    public RNFritzVisionObject(ReactApplicationContext reactContext){
        super(reactContext);
    }

    @ReactMethod
    public void predict(String imageURI, Promise promise){
        try{
            // Create predictor options
            FritzVisionObjectPredictorOptions options = new FritzVisionObjectPredictorOptions.Builder()
                    .confidenceThreshold(CONFIDENCE_THRESHOLD)
                    .maxObjects(MAX_OBJECT)
                    .build();

            final FritzVisionObjectPredictor objectPredictor = new FritzVisionObjectPredictor(options);


            Bitmap img = Utils.getBitmapFromURL(imageURI);

            if(img != null){

                FritzVisionImage visionImage = FritzVisionImage.fromBitmap(img);

                FritzVisionObjectResult objectResult = objectPredictor.predict(visionImage);

                Response output = new Response();

                output.setVisionLabelsAndBounding(objectResult.getVisionObjects());

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
        return "RNFritzVisionObject";
    }
}
