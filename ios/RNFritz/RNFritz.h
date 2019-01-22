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

-(void) catchException: (NSException *) exception;
-(void) initializeDetection: (RCTPromiseResolveBlock)resolve rejector:(RCTPromiseRejectBlock)reject;
-(void) onSuccess: (NSArray *)objects;
-(void) onError: (NSError *)error;


@end
