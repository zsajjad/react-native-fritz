package com.rnfritz.CustomModel;

import android.content.Context;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReadableMap;

import ai.fritz.core.CustomModel;

public class RNFritzCustomModel extends CustomModel {

    private static final String MODEL_PATH = "file:///android_asset/mnist.tflite";
    private static final String MODEL_ID = "ca8f473d4d404e6a91bca565a106e7df";
    private static final int MODEL_VERSION = 1;

    public RNFritzCustomModel(Context context) {
        super(MODEL_PATH, MODEL_ID, MODEL_VERSION);

    }
}
