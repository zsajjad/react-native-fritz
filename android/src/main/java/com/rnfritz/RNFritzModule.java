
package com.rnfritz;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;


import ai.fritz.core.Fritz;

public class RNFritzModule extends ReactContextBaseJavaModule {
//    private static final String API_KEY = ;
 private boolean fritzInitDone = false;
// private static final float CONFIDENCE_THRESHOLD = 0.7f;
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
  
  @Override
  public String getName() {
    return "RNFritz";
  }
}