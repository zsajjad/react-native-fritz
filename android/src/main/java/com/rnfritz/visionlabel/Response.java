package com.rnfritz.visionlabel;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;

import java.util.List;

import ai.fritz.vision.FritzVisionLabel;

 public class Response {
    private WritableMap result;
    private WritableArray visionLabels = Arguments.createArray();

    public void setVisionLabels(List<FritzVisionLabel> labels){
        for(int i = 0; i < labels.size(); i++){

            result = Arguments.createMap();
            FritzVisionLabel obj =  labels.get(i);

            result.putString("text", obj.getText());
            result.putDouble("confidence", obj.getConfidence());

            visionLabels.pushMap(result);
        }
    }

     public WritableMap getOutput(){
        result = Arguments.createMap();
        result.putArray("visionLabels", visionLabels);
        return result;
     }
 }
