//
//  RNFritzVisionImageLabeling.h
//  RNFritz
//
//  Created by Zain Sajjad on 22/01/2019.
//

#ifndef RNFritzVisionImageLabeling_h
#define RNFritzVisionImageLabeling_h

#if __has_include(<FritzVisionLabelModel/FritzVisionLabelModel.h>)
#import <React/RCTBridgeModule.h>

@interface RNFritzVisionImageLabeling : NSObject <RCTBridgeModule> {
    
}

@end

#else
@interface RNFritzVisionImageLabeling : NSObject
@end
#endif

#endif /* RNFritzVisionImageLabeling_h */

