//
//  RNFritzVisionObjectDetecion.h
//  RNFritz
//
//  Created by Zain Sajjad on 22/01/2019.
//

#ifndef RNFritzVisionObjectDetecion_h
#define RNFritzVisionObjectDetecion_h

#if __has_include(<FritzVisionObjectModel/FritzVisionObjectModel.h>)
#import <React/RCTBridgeModule.h>

@interface RNFritzVisionObjectDetection : NSObject <RCTBridgeModule> {
    
}

@end

#else
@interface RNFritzVisionObjectDetection : NSObject
@end
#endif

#endif /* RNFritzVisionObjectDetecion_h */
