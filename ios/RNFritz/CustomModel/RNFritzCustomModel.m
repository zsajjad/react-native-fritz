//
//  RNFritzCustomModel.m
//  RNFritz
//
//  Created by Zain Sajjad on 23/01/2019.
//

#import <React/RCTLog.h>
#import "RNFritz.h"
#import "RNFritzUtils.h"
#import "FritzCustomModel.h"
#import "RNFritzCustomModel.h"

@import CoreML;
@import Vision;
@import FritzVision;

@implementation RNFritzCustomModel
BOOL initialized = false;

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()

- (NSMutableArray *) prepareOutput: (NSArray *)labels {
    NSMutableArray *output = [NSMutableArray array];
    for (VNClassificationObservation *label in labels) {
        [output addObject:@{
                            @"label": [label valueForKey:@"description"],
                            @"description": [label valueForKey:@"description"],
                            @"confidence": [label valueForKey:@"confidence"],
                            }];
    }
    return output;
}

RCT_REMAP_METHOD(detectFromImage,
                 detectFromImage:(NSDictionary *)params
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject
                 ) {
    if (@available(iOS 11.0, *)) {

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        RNFritz *fritz = [[RNFritz alloc] init];
//        if (!initialized) {
//            [[FritzCustomModel alloc] init];
//        }
        @try {
            [fritz initializeDetection:resolve rejector:reject];
            NSDictionary *options = [[NSDictionary alloc] init];
            
            NSString *imagePath = [params valueForKey:@"imagePath"];
            NSURL *imageUrl = [[NSURL alloc] initWithString:imagePath];
            NSData *imageData = [NSData dataWithContentsOfURL:imageUrl];

            
            NSPredicate *predicate = [NSPredicate
                                      predicateWithFormat:@"self.confidence >= %f",
                                      [[params valueForKey:@"threshold"] floatValue]];
            long limit = [[params valueForKey:@"resultLimit"] integerValue];

            NSURL *modelUrl = [[NSBundle mainBundle] URLForResource:@"CarRecognition" withExtension:@"mlmodelc"];
            NSError *error;
            
            MLModel *model = [MLModel modelWithContentsOfURL:modelUrl error:&error].fritz;
            VNCoreMLModel *visionModel = [VNCoreMLModel modelForMLModel:model error:&error];
            if (error) {
                RCTLog(@"%@", error.debugDescription);
            }
            VNCoreMLRequest *modelRequest = [[VNCoreMLRequest alloc] initWithModel:visionModel completionHandler: (VNRequestCompletionHandler) ^(VNRequest *request, NSError *error){
                dispatch_async(dispatch_get_main_queue(), ^{
                    @try {
                        if (error != nil) {
                            [fritz onError:error];
                            return;
                        }
                        NSArray *temp = [request.results filteredArrayUsingPredicate:predicate];
                        NSArray *objects = [temp subarrayWithRange:NSMakeRange(0, MIN(limit, temp.count))];
                        [fritz onSuccess:[self prepareOutput:objects]];
                    }
                    @catch (NSException *e) {
                        [fritz catchException:e];
                    }
                });
            }];
            VNImageRequestHandler *handler = [[VNImageRequestHandler alloc] initWithData:imageData options:options];
            [handler performRequests:@[modelRequest] error:&error];
        }
        @catch (NSException *e) {
            [fritz catchException:e];
        }
    });
    } else {
        resolve(@NO);
    }
    
}

@end
