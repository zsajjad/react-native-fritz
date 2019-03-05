//
//  RNFritzUtils.m
//  RNFritz
//
//  Created by Zain Sajjad on 22/01/2019.
//

#import <Foundation/Foundation.h>
#import <React/RCTLog.h>
#import "RNFritzUtils.h"
@import FritzVision;

@implementation RNFritzUtils

+ (UIImage *) getUIImage: (NSString *)imagePath {
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imagePath]];
    return [UIImage imageWithData:imageData];
}

+ (FritzVisionImage *) getFritzVisionImage: (NSString *)imagePath {
    UIImage *image = [self getUIImage:imagePath];
    FritzVisionImage *visionImage = [[FritzVisionImage alloc] initWithImage:image];
    if (!visionImage) {
        @throw [NSException exceptionWithName:@"failure" reason:@"Unable to process image" userInfo:nil];
    }
    return visionImage;
}

+ (NSError *) errorFromException: (NSException *)exception {
    NSDictionary *exceptionInfo = @{
                                    @"name": exception.name,
                                    @"reason": exception.reason,
                                    @"description": exception.description,
//                                    @"callStackReturnAddresses": exception.callStackReturnAddresses,
//                                    @"callStackSymbols": exception.callStackSymbols,
                                    };
    return [[NSError alloc] initWithDomain:@"RNFritz"
                                      code:0
                                  userInfo:exceptionInfo];
}

+ (NSData *) getImageData: (NSString *)path {
    return [NSData dataWithContentsOfURL:[[NSURL alloc] initWithString:path]];
}

+ (FritzMLModel *) getCustomMLModel: (NSDictionary *)modelParams  API_AVAILABLE(ios(11.0)){
    NSString *modelName = [modelParams valueForKey:@"name"];
    NSURL *modelUrl = [[NSBundle mainBundle] URLForResource:modelName withExtension:@"mlmodelc"];
    RCTLog(@"%@", [[NSBundle mainBundle] bundleURL]);
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
    if (error) {
        @throw error;
    }
    FritzMLModel* fritzModel = [[FritzMLModel alloc]
                                initWithIdentifiedModel:model
                                config:config
                                sessionManager:sessionManager];
    return fritzModel;
}

@end
