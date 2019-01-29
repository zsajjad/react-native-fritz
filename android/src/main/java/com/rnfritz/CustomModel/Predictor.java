package com.rnfritz.CustomModel;

import android.graphics.Bitmap;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;
import com.rnfritz.Utils;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.util.AbstractMap;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.PriorityQueue;

import ai.fritz.customtflite.FritzTFLiteInterpreter;

public class Predictor {

    private String MODEL;
    private String MODEL_ID;
    private String MODEL_TYPE;
    private String MODEL_LABEL;

    private int FILTER_STAGES;
    private int MODEL_VERSION;
    private int RESULT_LENGTH;
    private int DIM_PIXEL_SIZE;
    private int DIM_IMG_SIZE_X;
    private int DIM_IMG_SIZE_Y;
    private int RESULTS_TO_SHOW;
    private float THRESHOLD = 0.4f;


    private static final int DIM_BATCH_SIZE = 1;
    private static final int NUM_BYTES_PER_CHANNEL = 4;


    private float[][] output;
    private ByteBuffer imgData;
    private List<String> labelList;
    private ReactApplicationContext mReactContext;
    private PriorityQueue<Map.Entry<String, Float>> sortedLabels = null;

    private FritzTFLiteInterpreter tflite = null;


    public Predictor(ReactApplicationContext reactContext, ReadableMap params) throws IOException {
        super();
        mReactContext = reactContext;
        initializeModel(params);
    }

    private void setDefaultValues(){
        MODEL = null;
        MODEL_ID = null;
        MODEL_TYPE = null;
        MODEL_VERSION = 1;
        MODEL_LABEL = null;

        FILTER_STAGES = 1;
        DIM_PIXEL_SIZE = 1;
        RESULT_LENGTH = 10;
        DIM_IMG_SIZE_X = 28;
        DIM_IMG_SIZE_Y = 28;
        RESULTS_TO_SHOW = 3;

        output = null;
        imgData = null;
        labelList = null;
        sortedLabels = null;

    }

    private void initializeModel(ReadableMap params) throws IOException {

        setDefaultValues();

        MODEL = params.hasKey("model") ? params.getString("model") : MODEL;
        MODEL_TYPE = params.hasKey("type") ? params.getString("type") : MODEL_TYPE;
        MODEL_ID = params.hasKey("modelId") ? params.getString("modelId") : MODEL_ID;
        ReadableMap imageDimensions = params.hasKey("imageDimensions") ? params.getMap("imageDimensions") : null;

        if(MODEL == null || MODEL_TYPE == null || MODEL_ID == null){
            throw new Error("Parameters missing");
        }

        String modelPath = "file:///android_asset/" + MODEL + '.' + MODEL_TYPE;


        MODEL_LABEL = params.hasKey("modelLabel") ? params.getString("modelLabel") : MODEL_LABEL;
        MODEL_VERSION = params.hasKey("modelVersion") ? params.getInt("modelVersion") : MODEL_VERSION;

        if(imageDimensions != null){
            DIM_PIXEL_SIZE = imageDimensions.hasKey("pixel") ? imageDimensions.getInt("pixel") : DIM_PIXEL_SIZE;
            DIM_IMG_SIZE_X = imageDimensions.hasKey("width") ? imageDimensions.getInt("width") : DIM_IMG_SIZE_X;
            DIM_IMG_SIZE_Y = imageDimensions.hasKey("height") ? imageDimensions.getInt("height") : DIM_IMG_SIZE_Y;
        }

        imgData = ByteBuffer.allocateDirect(DIM_BATCH_SIZE * DIM_IMG_SIZE_X * DIM_IMG_SIZE_Y * DIM_PIXEL_SIZE * NUM_BYTES_PER_CHANNEL);
        imgData.order(ByteOrder.nativeOrder());

        try{
            tflite = FritzTFLiteInterpreter.create(new RNCustomModel(modelPath, MODEL_ID, MODEL_VERSION));
            if(MODEL_LABEL != null){
                labelList = loadLabelList(mReactContext, MODEL_LABEL);
                RESULT_LENGTH = labelList.size();
            }
        } catch (IOException e) {
            e.printStackTrace();
            throw e;
        }
    }


    public void predict(ReadableMap params, Promise promise){
        try {
            String imageURI = params.getString("imagePath");
            FILTER_STAGES = params.hasKey("filterStages") ? params.getInt("filterStages") : FILTER_STAGES;
            RESULT_LENGTH = params.hasKey("classificationLength") ? params.getInt("classificationLength") : RESULT_LENGTH;
            RESULTS_TO_SHOW = params.hasKey("resultLimit") ? params.getInt("resultLimit") : RESULTS_TO_SHOW;
            THRESHOLD = params.hasKey("threshold") ? (float) params.getDouble("threshold") : THRESHOLD;

            sortedLabels = new PriorityQueue<>(
                    RESULTS_TO_SHOW,
                    new Comparator<Map.Entry<String, Float>>() {
                        @Override
                        public int compare(Map.Entry<String, Float> o1, Map.Entry<String, Float> o2) {
                            return (o1.getValue()).compareTo(o2.getValue());
                        }
                    });

            Bitmap bitmap = Utils.getBitmapFromURL(imageURI);
            bitmap = Bitmap.createScaledBitmap(bitmap, DIM_IMG_SIZE_X, DIM_IMG_SIZE_Y,false);

            imgData = Utils.convertBitmapToByteBuffer(bitmap, imgData, DIM_IMG_SIZE_X, DIM_IMG_SIZE_Y, DIM_PIXEL_SIZE);

            output = new float[FILTER_STAGES][RESULT_LENGTH];

            tflite.run(imgData, output);
            printTopKLabels();

            WritableMap result = Arguments.createMap();
            for (Map.Entry<String, Float> sortedLabel : sortedLabels) {
                if(sortedLabel.getValue() >= THRESHOLD){
                    result.putDouble(sortedLabel.getKey(), sortedLabel.getValue());
                }
            }

            promise.resolve(result);

        } catch (Exception e) {
            e.printStackTrace();
            promise.reject(e);
        }
    }


    private float getProbability(int labelIndex) {
        return output[0][labelIndex];
    }

    private void printTopKLabels() {
        for (int i = 0; i < RESULT_LENGTH; ++i) {
            sortedLabels.add(new AbstractMap.SimpleEntry<>(labelList.get(i), (float) Math.floor(getProbability(i) * 100) / 100));
            if (sortedLabels.size() > RESULTS_TO_SHOW) {
                sortedLabels.poll();
            }
        }
    }


    /** Reads label list from Assets. */
    private List<String> loadLabelList(ReactApplicationContext context, String modelLabel) throws IOException {
        List<String> labelList = new ArrayList<String>();
        BufferedReader reader = new BufferedReader(new InputStreamReader(context.getAssets().open(modelLabel)));
        String line;
        while ((line = reader.readLine()) != null) {
            labelList.add(line);
        }
        reader.close();
        return labelList;
    }
}
