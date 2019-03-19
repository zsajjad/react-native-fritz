//
//  RNFritzCustomModel.m
//  RNFritz
//
//  Created by Zain Sajjad on 23/01/2019.
//

#import <React/RCTLog.h>
#import "RNFritzUtils.h"
#import "RNFritzCustomModel.h"

@import CoreML;
@import Vision;
@import FritzVision;

@implementation RNFritzCustomModel {
    NSMutableDictionary *models;
};

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

+ (BOOL)requiresMainQueueSetup
{
    return YES;
}

- (instancetype) init {
    self = [super init];
    models = [[NSMutableDictionary alloc] init];
    return self;
}
RCT_EXPORT_MODULE()

- (NSMutableArray *) prepareOutput: (NSArray *)labels predicate:(NSPredicate *)predicate limit:(long *)limit {
    NSMutableArray *output = [NSMutableArray array];
    NSArray *temp = [labels filteredArrayUsingPredicate:predicate];
    NSArray *objects = [temp subarrayWithRange:NSMakeRange(0, MIN(limit, temp.count))];
    for (VNClassificationObservation *label in objects) {
        [output addObject:@{
                            @"label": [label valueForKey:@"description"],
                            @"description": [label valueForKey:@"description"],
                            @"confidence": [label valueForKey:@"confidence"],
                            }];
    }
    return output;
}

- (VNCoreMLModel *) loadModel: (NSDictionary *)modelParams {
    NSString *modelName = [modelParams valueForKey:@"name"];
    NSURL *modelUrl = [[NSBundle mainBundle] URLForResource:modelName withExtension:@"mlmodelc"];
    if (!modelUrl) {
        @throw [[NSException alloc] initWithName:@"MODEL_NOT_FOUND" reason:@"Model url is nil" userInfo:nil];
    }
    NSError *error;
    FritzModelConfiguration* config = [[FritzModelConfiguration alloc]
                                       initWithIdentifier:[modelParams valueForKey:@"modelIdentifier"]
                                       version:[[modelParams valueForKey:@"modelVersion"] integerValue]
                                       cpuAndGPUOnly:false];
    SessionManager* sessionManager = [[FritzCore configuration] sessionManager];
    FritzManagedModel* managedModel = [[FritzManagedModel alloc]
                                       initWithModelConfig:config
                                       sessionManager:sessionManager
                                       loadActive:true];
    
    MLModel *model = [MLModel modelWithContentsOfURL:modelUrl error:&error];
    FritzMLModel* fritzModel = [[FritzMLModel alloc]
                                initWithIdentifiedModel:model
                                config:config
                                sessionManager:sessionManager];
    
    VNCoreMLModel *visionModel = [VNCoreMLModel modelForMLModel:fritzModel error:&error];
    if (error) {
        @throw error;
    }
    return visionModel;
}

- (VNCoreMLModel *) getModel: (NSDictionary *)modelParams {
    NSString *modelName = [modelParams valueForKey:@"name"] ;
    if (![models valueForKey:modelName]) {
        VNCoreMLModel *model = [self loadModel:modelParams];
        [models setValue:model forKey:modelName];
    }
    return [models valueForKey:modelName];
}

- (VNCoreMLModel *) getClassModel:(NSString *)modelName {
    if (![models valueForKey:modelName]) {
        return nil;
    }
    return [models valueForKey:modelName];
}

RCT_REMAP_METHOD(initializeModel,
                 initializeModel:
                (NSDictionary *)params
                resolver:(RCTPromiseResolveBlock)resolve
                rejecter:(RCTPromiseRejectBlock)reject) {
    if (@available(iOS 11.0, *)) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            @try {
                [self getModel:params];
                dispatch_async(dispatch_get_main_queue(), ^{
                    resolve(@YES);
                });
            }
            @catch (NSException *exception) {
                NSError *error = [RNFritzUtils errorFromException:exception];
                dispatch_async(dispatch_get_main_queue(), ^{
                    reject([NSString stringWithFormat: @"%ld", [error code]],
                           [error description],
                           error);
                });
            }
        });
    } else {
        reject(0, @"CORE_ML_UNAVAILABLE", nil);
    }
}


RCT_REMAP_METHOD(predictFromImage,
                 predictFromImage:
                 (NSString *)modelName
                 params:(NSDictionary *)params
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject
                 ) {
    if (@available(iOS 11.0, *)) {

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @try {
            NSDictionary *options = [[NSDictionary alloc] init];
            NSData *imageData = [RNFritzUtils getImageData:[params valueForKey:@"imagePath"]];

            VNCoreMLModel *model = [self getClassModel:modelName];
            VNCoreMLRequest *modelRequest =
                [[VNCoreMLRequest alloc]
                 initWithModel:model
                 completionHandler:(VNRequestCompletionHandler) ^(VNRequest *request, NSError *error){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        @try {
                            if (error != nil) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    reject([NSString stringWithFormat: @"%ld", [error code]],
                                           [error description],
                                           error);
                                });
                                return;
                            }
                            NSPredicate *predicate = [NSPredicate
                                                      predicateWithFormat:@"self.confidence >= %f",
                                                      [[params valueForKey:@"threshold"] floatValue]];
                            long limit = [[params valueForKey:@"resultLimit"] integerValue];
                            NSArray *output = [self prepareOutput:request.results predicate:predicate limit:&limit];
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
                    });
                 }];
            VNImageRequestHandler *handler = [[VNImageRequestHandler alloc] initWithData:imageData options:options];
            NSError *error;
            [handler performRequests:@[modelRequest] error:&error];
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
    } else {
        resolve(@NO);
    }
    
}

@end
