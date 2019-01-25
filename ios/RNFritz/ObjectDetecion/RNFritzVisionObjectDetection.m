//
//  RNFritzVisionObjectDetection.m
//  RNFritz
//
//  Created by Zain Sajjad on 22/01/2019.
//
#import <React/RCTLog.h>
#import "RNFritzVisionObjectDetection.h"

#if __has_include(<FritzVisionObjectModel/FritzVisionObjectModel.h>)

#import "RNFritz.h"
#import "RNFritzUtils.h"

@import FritzVisionObjectModel;
@implementation RNFritzVisionObjectDetection

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()

- (FritzVisionObjectModelOptions *) getLabelModelOptions: (NSDictionary *)params {
    return [[FritzVisionObjectModelOptions alloc]
            initWithThreshold:[[params valueForKey:@"threshold"] floatValue]
            iouThreshold:[[params valueForKey:@"iouThreshold"] floatValue]
            numResults:[[params valueForKey:@"resultLimit"] doubleValue]];
}


- (NSMutableArray *) prepareOutput: (NSArray *)labels {
    NSMutableArray *output = [NSMutableArray array];
    for (FritzVisionLabel *label in labels) {
        [output addObject:@{
                            @"label": [label valueForKey:@"label"],
                            @"description": [label valueForKey:@"description"],
//                            @"confidence": @([[label valueForKey:@"confidence"] floatValue]),
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
        RNFritz *fritz = [[RNFritz alloc] init];
        @try {
            [fritz initializeDetection:resolve rejector:reject];
            NSString *imagePath = [params valueForKey:@"imagePath"];
            FritzVisionImage *visionImage = [RNFritzUtils getFritzVisionImage:imagePath];
            FritzVisionObjectModelOptions *options = [self getLabelModelOptions:params];
            FritzVisionObjectModel *objectModel = [FritzVisionObjectModel new];
            [objectModel
             predict:visionImage
             options:options
             completion:^(NSArray *objects, NSError *error) {
                 @try {
                     if (error != nil) {
                         [fritz onError:error];
                         return;
                     }
                     [fritz onSuccess:[self prepareOutput:objects]];
                 }
                 @catch (NSException *e) {
                     [fritz catchException:e];
                 }
             }];
        }
        @catch (NSException *e) {
            [fritz catchException:e];
        }
    });
    
}


@end

#else
@implementation RNFritzVisionObjectDetection

@end
#endif
