package com.rnfritz.CustomModel;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import java.io.IOException;
import java.util.HashMap;


public class RNFritzCustomModel extends ReactContextBaseJavaModule{

    private ReactApplicationContext mReactContext;
    private HashMap<String, Predictor> fritzModelMap = new HashMap<>();
    private Predictor fritzModel = null;


    public RNFritzCustomModel(ReactApplicationContext reactContext){
        super(reactContext);
        mReactContext = reactContext;
    }

    @ReactMethod
    public void initializeModel(ReadableMap params, Promise promise){
        try{
            String model = params.hasKey("model") ? params.getString("model") : null;
            if(model == null){
                promise.resolve(false);
            }
            Predictor predictor = new Predictor(mReactContext, params);

            if(fritzModelMap.get(model) != null){
                fritzModelMap.remove(model);
            }
            fritzModelMap.put(model, predictor);
            promise.resolve(true);

        } catch (IOException e) {
            e.printStackTrace();
            promise.resolve(false);
        }
    }

    @ReactMethod
    public void predictFromImage(String model, ReadableMap params, Promise promise){
        if(!params.hasKey("imagePath") || model == null){
            promise.reject("Missing params", "Missing parameters");
        }

        fritzModel = fritzModelMap.get(model);
        fritzModel.predict(params, promise);
    }

    @Override
    public String getName() {
        return "RNFritzCustomModel";
    }
}
