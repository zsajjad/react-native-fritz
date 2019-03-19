//
//  RNFritzVisionImageStyling.m
//  RNFritz
//
//  Created by Zain Sajjad on 22/01/2019.
//

#import "RNFritzVisionImageStyling.h"

#if __has_include(<FritzVisionStyleModelPaintings/FritzVisionStyleModelPaintings.h>)

#import "RNFritzUtils.h"

@import FritzVisionStyleModelPaintings;

@implementation RNFritzVisionImageStyling {
    NSMutableDictionary *models;
}

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

- (FritzVisionStyleModelOptions *) getLabelModelOptions: (NSDictionary *)params {
    FritzVisionStyleModelOptions * options = [FritzVisionStyleModelOptions new];
//    options.imageCropAndScaleOption = FritzVisionCropAndScaleCenterCrop;
    return options;
}


- (FritzVisionStyleModel *) loadModel: (NSDictionary *)modelParams {
    NSString *modelName = [modelParams valueForKey:@"name"];
    if (![[modelParams valueForKey:@"customModel"] boolValue]) {
        return [FritzVisionStyleModel valueForKey:modelName];
    }

    if (@available(iOS 11.0, *)) {
        NSError *error;
        FritzMLModel *model = [RNFritzUtils getCustomMLModel:modelParams];
        FritzVisionStyleModel *styleModel = [[FritzVisionStyleModel alloc] initWithFritzMLModel:model error:&error];
        if (error) {
            @throw error;
        }
        return styleModel;
    }
    return nil;
}

- (FritzVisionStyleModel *) getModel: (NSDictionary *)modelParams {
    NSString *modelIdentifier = [modelParams valueForKey:@"modelIdentifier"] ;
    if (![models valueForKey:modelIdentifier]) {
        FritzVisionStyleModel *model = [self loadModel:modelParams];
        [models setValue:model forKey:modelIdentifier];
    }
    return [models valueForKey:modelIdentifier];
}


- (FritzVisionStyleModel *) getClassModel:(NSString *)modelIdentifier {
    if (![models valueForKey:modelIdentifier]) {
        return nil;
    }
    return [models valueForKey:modelIdentifier];
}


- (NSDictionary *) prepareOutput: (CVPixelBufferRef)pixelBuffer {
    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:pixelBuffer];
    
    CIContext *temporaryContext = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [temporaryContext
                             createCGImage:ciImage
                             fromRect:CGRectMake(0, 0,
                                                 CVPixelBufferGetWidth(pixelBuffer),
                                                 CVPixelBufferGetHeight(pixelBuffer))];
    
    UIImage *uiImage = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    long long milliseconds = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
    NSString *fileName = [[NSString alloc] initWithFormat:@"%lld.png", milliseconds];
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
    
    // Save image.
    [UIImagePNGRepresentation(uiImage) writeToFile:filePath atomically:YES];
    
    NSDictionary *output = @{
                            @"imagePath": filePath,
                            };
    return output;
}



RCT_REMAP_METHOD(initializeModel,
                 initializeModel:
                 (NSDictionary *)modelParams
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject) {
    if (@available(iOS 11.0, *)) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            @try {
                [self getModel:modelParams];
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



RCT_REMAP_METHOD(style,
                 style:
                 (NSString *)modelIdentifier
                 params:(NSDictionary *)params
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject
                 ) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @try {
            NSString *imagePath = [params valueForKey:@"imagePath"];
            FritzVisionImage *visionImage = [RNFritzUtils getFritzVisionImage:imagePath];
            FritzVisionStyleModelOptions *options = [self getLabelModelOptions:params];
            FritzVisionStyleModel *styleModel = [self getClassModel:modelIdentifier];
            [styleModel
             predict:visionImage
             options:options
             completion:^(CVPixelBufferRef result, NSError *error){
                 @try {
                     if (error != nil) {
                         dispatch_async(dispatch_get_main_queue(), ^{
                             reject([NSString stringWithFormat: @"%ld", [error code]],
                                    [error description],
                                    error);
                         });
                         return;
                     }
                     NSDictionary *output = [self prepareOutput:result];
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
