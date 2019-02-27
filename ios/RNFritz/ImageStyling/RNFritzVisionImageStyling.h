//
//  RNFritzVisionImageStyling.h
//  RNFritz
//
//  Created by Zain Sajjad on 22/01/2019.
//

#ifndef RNFritzVisionImageStyling_h
#define RNFritzVisionImageStyling_h

#if __has_include(<FritzVisionStyleModelPaintings/FritzVisionStyleModelPaintings.h>)

#import <React/RCTBridgeModule.h>

@interface RNFritzVisionImageStyling : NSObject <RCTBridgeModule> {
    
}

@end

#else
@interface RNFritzVisionImageLabeling : NSObject
@end
#endif

#endif /* RNFritzVisionImageStyling_h */

