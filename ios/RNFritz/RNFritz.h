//
//  RNFritz.h
//  RNFritz
//
//  Created by Zain Sajjad on 22/01/2019.
//

#import <React/RCTBridgeModule.h>
#import "RNFritzUtils.h"
@import FritzCore;

@interface RNFritz : NSObject <RCTBridgeModule>

-(void) initialize: (RCTPromiseResolveBlock)resolve rejector:(RCTPromiseRejectBlock)reject;

@end
