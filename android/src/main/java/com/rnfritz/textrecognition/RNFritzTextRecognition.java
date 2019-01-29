package com.rnfritz.textrecognition;

import android.graphics.Bitmap;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.rnfritz.CustomModel.RNFritzCustomModel;
import com.rnfritz.Utils;

import java.io.IOException;

import ai.fritz.customtflite.FritzTFLiteInterpreter;


public class RNFritzTextRecognition extends ReactContextBaseJavaModule {
    private final ReactApplicationContext mReactContext;

    public RNFritzTextRecognition(ReactApplicationContext reactContext){
        super(reactContext);
        mReactContext = reactContext;
    }

    @ReactMethod
    public void predict(String imageURI, Promise promise){
        // Create an interpreter
        FritzTFLiteInterpreter tflite = null;
        try {
            tflite = FritzTFLiteInterpreter.create(new RNFritzCustomModel(mReactContext));
//            Bitmap img = Utils.getBitmapFromURL(imageURI);
            // Run prediction with input / output buffers
//            Object outputBuffer = null;
//            tflite.run(img, outputBuffer);
            promise.resolve("success");

        } catch (IOException e) {
            e.printStackTrace();
            System.out.println(e);
            promise.reject(e);
        }
    }

//    @ReactMethod
//    public void initImageRecognizer(String id, ReadableMap data, Promise promise) {
//        try {
//            String model = data.getString("model");
////            String labels = data.getString("labels");
////            Integer imageMean = data.hasKey("imageMean") ? data.getInt("imageMean") : null;
////            Double imageStd = data.hasKey("imageStd") ? data.getDouble("imageStd") : null;
//
//            promise.resolve(true);
//        } catch (Exception e) {
//            promise.reject(e);
//        }
//    }

//    @ReactMethod
//    public void recognize(String id, ReadableMap data, Promise promise) {
//        try {
//            String image = data.getString("image");
//            String inputName = data.hasKey("inputName") ? data.getString("inputName") : null;
//            Integer inputSize = data.hasKey("inputSize") ? data.getInt("inputSize") : null;
//            String outputName = data.hasKey("outputName") ? data.getString("outputName") : null;
//            Integer maxResults = data.hasKey("maxResults") ? data.getInt("maxResults") : null;
//            Double threshold = data.hasKey("threshold") ? data.getDouble("threshold") : null;
//
//            ImageRecognizer imageRecognizer = imageRecognizers.get(id);
//            WritableArray result = imageRecognizer.recognizeImage(image, inputName, inputSize, outputName, maxResults, threshold);
//            promise.resolve(result);
//        } catch (Exception e) {
//            promise.reject(e);
//        }
//    }

    @Override
    public String getName() {
        return "RNFritzTextRecognition";
    }
}
