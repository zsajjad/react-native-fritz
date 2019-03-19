//
//  RNFritzVisionImageLabeling.m
//  RNFritz
//
//  Created by Zain Sajjad on 22/01/2019.
//

#import "RNFritzVisionImageLabeling.h"

#if __has_include(<FritzVisionLabelModel/FritzVisionLabelModel.h>)

#import "RNFritzUtils.h"

@import FritzVisionLabelModel;

@implementation RNFritzVisionImageLabeling 

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()

- (FritzVisionLabelModelOptions *) getLabelModelOptions: (NSDictionary *)params {
    return [[FritzVisionLabelModelOptions alloc]
            initWithThreshold:[[params valueForKey:@"threshold"] floatValue]
            numResults:[[params valueForKey:@"resultLimit"] doubleValue]];
}


- (NSMutableArray *) prepareOutput: (NSArray *)labels {
    NSMutableArray *output = [NSMutableArray array];
    for (FritzVisionLabel *label in labels) {
        [output addObject:@{
                            @"label": [label valueForKey:@"label"],
                            @"description": [label valueForKey:@"description"],
                            @"confidence": @([[label valueForKey:@"confidence"] floatValue]),
                            }];
    }
    return output;
}

RCT_REMAP_METHOD(detect,
                 detect:(NSDictionary *)params
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject
                 ) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @try {
            NSString *imagePath = [params valueForKey:@"imagePath"];
            FritzVisionImage *visionImage = [RNFritzUtils getFritzVisionImage:imagePath];
            FritzVisionLabelModelOptions *options = [self getLabelModelOptions:params];
            FritzVisionLabelModel *visionModel = [FritzVisionLabelModel new];
            [visionModel
             predict:visionImage
             options:options
             completion:^(NSArray *objects, NSError *error) {
                 @try {
                     if (error != nil) {
                         dispatch_async(dispatch_get_main_queue(), ^{
                             reject([NSString stringWithFormat: @"%ld", [error code]],
                                    [error description],
                                    error);
                         });
                         return;
                     }
                     NSArray *output = [self prepareOutput:objects];
                     dispatch_async(dispatch_get_main_queue(), ^{
                         resolve(output);
                     });
                 }
                 @catch (NSException *e) {
                     NSError *error = [RNFritzUtils errorFromException:e];
                     dispatch_async(dispatch_get_main_queue(), ^{
                         reject([NSString stringWithFormat: @"%ld", [error code]],
                                [error description],
                                error);
                     });
                 }
             }];
        }
        @catch (NSException *e) {
            NSError *error = [RNFritzUtils errorFromException:e];
            dispatch_async(dispatch_get_main_queue(), ^{
                reject([NSString stringWithFormat: @"%ld", [error code]],
                       [error description],
                       error);
            });
        }
    });
    
}

@end

#else

@implementation RNFritzVisionImageLabeling

@end
#endif
