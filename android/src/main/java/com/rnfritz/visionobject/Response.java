package com.rnfritz.visionobject;

import android.graphics.RectF;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;

import java.util.List;

import ai.fritz.vision.FritzVisionLabel;
import ai.fritz.vision.FritzVisionObject;


public class Response {
    private WritableMap result;
    private WritableArray visionObjects = Arguments.createArray();

    public void setVisionLabelsAndBounding(List<FritzVisionObject> labels){
        for(int i = 0; i < labels.size(); i++){

            result = Arguments.createMap();
            FritzVisionObject obj =  labels.get(i);

            FritzVisionLabel visionLabel = obj.getVisionLabel();
            RectF bounding = obj.getBoundingBox();

            result.putString("text", visionLabel.getText());
            result.putDouble("confidence", visionLabel.getConfidence());

            result.putDouble("bottom", bounding.bottom);
            result.putDouble("top", bounding.top);
            result.putDouble("left", bounding.left);
            result.putDouble("right", bounding.right);

            visionObjects.pushMap(result);
        }
    }

    public WritableMap getOutput(){
        result = Arguments.createMap();
        result.putArray("visionObjects", visionObjects);
        return result;
    }
}
