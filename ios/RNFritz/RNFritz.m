//
//  RNFritz.m
//  RNFritz
//
//  Created by Zain Sajjad on 22/01/2019.
//

#import "RNFritz.h"
#import "RNFritzUtils.h"

@implementation RNFritz {
    Boolean configured;
    RCTPromiseResolveBlock _resolve;
    RCTPromiseRejectBlock _reject;
};


- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()

- (instancetype) init {
    self = [super init];
    [FritzCore configure];
    configured = true;
    return self;
}

+ (BOOL)requiresMainQueueSetup
{
    return YES;
}


-(void) initialize: (RCTPromiseResolveBlock)resolve rejector:(RCTPromiseRejectBlock)reject {
    if (@available(iOS 11.0, *)) {
        if (!configured) {
            [FritzCore configure];
            configured = true;
            resolve(@YES);
        } else {
            reject(0, @"Already configured", nil);
        }
    } else {
        reject(0, @"OS not supported", nil);
    }
}


@end
  
