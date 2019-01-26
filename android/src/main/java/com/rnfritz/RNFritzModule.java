
package com.rnfritz;

import android.content.pm.ApplicationInfo;
import android.graphics.Bitmap;
import android.os.Bundle;
import android.util.Log;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;


import ai.fritz.core.Fritz;
import ai.fritz.vision.inputs.FritzVisionImage;
import ai.fritz.visionlabel.FritzVisionLabelPredictor;
import ai.fritz.visionlabel.FritzVisionLabelPredictorOptions;
import ai.fritz.visionlabel.FritzVisionLabelResult;

public class RNFritzModule extends ReactContextBaseJavaModule {
//    private static final String API_KEY = ;
 private boolean fritzInitDone = false;
 private static final float CONFIDENCE_THRESHOLD = 0.7f;

 private final ReactApplicationContext mReactContext;

  public RNFritzModule(ReactApplicationContext reactContext) {
      super(reactContext);
      mReactContext = reactContext;
      initFritz();
  }

  private String appIdFromManifest(ReactApplicationContext reactContext){
     try{
         ApplicationInfo ai = reactContext.getPackageManager().getApplicationInfo(reactContext.getPackageName(), reactContext.getPackageManager().GET_META_DATA);
         Bundle bundle = ai.metaData;
         return bundle.getString("fritz_app_id");
     }catch(Throwable t){
         t.printStackTrace();
         return null;
     }
  }

  private void initFritz(){
      String appId = appIdFromManifest(mReactContext);
      if(appId != null && appId.length() > 0){
          init(appId);
      }
  }

  @ReactMethod
  public void init(String appId){
      if(fritzInitDone){
          Log.e("fritz", "Already initialized the Fritz React-Native SDK");
          return;
      }
          fritzInitDone = true;
          Fritz.configure(mReactContext, appId);
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
    return "RNFritz";
  }
}

// class DownloadImage extends AsyncTask<String, Void, Bitmap> {
//     public AsyncResponse delegate = null;
//
//     public DownloadImage(AsyncResponse asyncResponse) {
//         delegate = asyncResponse;
//     }
//
//     @Override
//    protected Bitmap doInBackground(String... urls) {
//        return getBitmapFromUrl(urls[0]);
//    }
//
//    protected void onPostExecute(Bitmap image) {
//        delegate.processFinish(image);
//    }


//}

