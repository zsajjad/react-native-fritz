package com.rnfritz.ObjectDetection;

import android.graphics.Bitmap;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.rnfritz.ObjectDetection.Response;
import com.rnfritz.Utils;

import ai.fritz.fritzvisionobjectmodel.FritzVisionObjectPredictor;
import ai.fritz.fritzvisionobjectmodel.FritzVisionObjectPredictorOptions;
import ai.fritz.fritzvisionobjectmodel.FritzVisionObjectResult;
import ai.fritz.vision.inputs.FritzVisionImage;

public class RNFritzVisionObjectDetection extends ReactContextBaseJavaModule {

    private float CONFIDENCE_THRESHOLD = 0.7f;
    private int MAX_OBJECT = 10;

    public RNFritzVisionObjectDetection(ReactApplicationContext reactContext){
        super(reactContext);
    }

    @ReactMethod
    public void predictFromImage(ReadableMap params, Promise promise){
        try{
            String imageURI = params.hasKey("imagePath") ? params.getString("imagePath") : null;
            CONFIDENCE_THRESHOLD = params.hasKey("threshold") ? (float) params.getDouble("threshold") : CONFIDENCE_THRESHOLD;
            MAX_OBJECT = params.hasKey("maxObject") ? params.getInt("maxObject") : MAX_OBJECT;

            if(imageURI == null){
                promise.reject("Missing params", "Missing parameters");
                return;
            }

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
        return "RNFritzVisionObjectDetection";
    }
}
