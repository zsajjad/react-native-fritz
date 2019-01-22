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


-(void) initializeDetection: (RCTPromiseResolveBlock)resolve rejector:(RCTPromiseRejectBlock)reject {
    if (!configured) {
        [FritzCore configure];
        configured = true;
    }
    _resolve = resolve;
    _reject = reject;
}

-(void) onError: (NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        self->_reject(
                [NSString stringWithFormat: @"%ld", [error code]],
                [error description],
                error);
    });
}

-(void) catchException: (NSException *)exception {
    NSError *error = [RNFritzUtils errorFromException:exception];
    [self onError:error];
}

-(void) onSuccess: (NSMutableArray *)output {
    dispatch_async(dispatch_get_main_queue(), ^{
        self->_resolve(output);
    });
}

@end
  
