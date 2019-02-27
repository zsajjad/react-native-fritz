//
//  RNFritzVisionImageStyling.m
//  RNFritz
//
//  Created by Zain Sajjad on 22/01/2019.
//

#import "RNFritzVisionImageStyling.h"

#if __has_include(<FritzVisionStyleModelPaintings/FritzVisionStyleModelPaintings.h>)

#import "RNFritz.h"
#import "RNFritzUtils.h"

@import FritzVisionStyleModelPaintings;

@implementation RNFritzVisionImageStyling {
    FritzVisionStyleModel *styleModel;
}

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()

- (FritzVisionStyleModelOptions *) getLabelModelOptions: (NSDictionary *)params {
    FritzVisionStyleModelOptions * options = [FritzVisionStyleModelOptions new];
//    options.imageCropAndScaleOption = FritzVisionCropAndScaleCenterCrop;
    return options;
}

- (FritzVisionStyleModel *) getModel {
    if (!styleModel) {
        // TODO Make this configurable from params
        styleModel = [FritzVisionStyleModel poppyField];
    }
    return styleModel;
}


- (NSMutableArray *) prepareOutput: (CVPixelBufferRef)pixelBuffer {
    NSMutableArray *output = [NSMutableArray array];
    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:pixelBuffer];
    
    CIContext *temporaryContext = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [temporaryContext
                             createCGImage:ciImage
                             fromRect:CGRectMake(0, 0,
                                                 CVPixelBufferGetWidth(pixelBuffer),
                                                 CVPixelBufferGetHeight(pixelBuffer))];
    
    UIImage *uiImage = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    
//    CIImage *ciImage = [[CIImage alloc] initWithCVPixelBuffer:pixelBuffer];
//    UIImage *uiImage = [[UIImage alloc] initWithCIImage:ciImage];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Image.png"];
    
    // Save image.
    [UIImagePNGRepresentation(uiImage) writeToFile:filePath atomically:YES];
    
    [output addObject:@{
                        @"imagePath": filePath,
                        }];
    return output;
}



RCT_REMAP_METHOD(style,
                 style:(NSDictionary *)params
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject
                 ) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        RNFritz *fritz = [[RNFritz alloc] init];
        @try {
            [fritz initializeDetection:resolve rejector:reject];
            NSString *imagePath = [params valueForKey:@"imagePath"];
            FritzVisionImage *visionImage = [RNFritzUtils getFritzVisionImage:imagePath];
            FritzVisionStyleModelOptions *options = [self getLabelModelOptions:params];
            FritzVisionStyleModel *styleModel = [self getModel];
            [styleModel
             predict:visionImage
             options:options
             completion:^(CVPixelBufferRef result, NSError *error){
                 @try {
                     if (error != nil) {
                         [fritz onError:error];
                         return;
                     }
                     [fritz onSuccess:[self prepareOutput:result]];
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

@implementation RNFritzVisionImageLabeling

@end
#endif
