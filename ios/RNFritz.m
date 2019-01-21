
#import <React/RCTLog.h>

#import "RNFritz.h"

@import FritzCore;
@import CoreML;
@import FritzVisionLabelModel;

@implementation RNFritz

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()

static NSString *const detectionNoResultsMessage = @"Something went wrong";

RCT_REMAP_METHOD(detectFromUri, detectFromUri:(NSString *)imagePath resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    if (!imagePath) {
        RCTLog(@"No image path found");
        resolve(@NO);
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imagePath]];
        UIImage *image = [UIImage imageWithData:imageData];
        
        if (!image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                RCTLog(@"No image found %@", imagePath);
                resolve(@NO);
            });
            return;
        }
        
        if (@available(iOS 11.0, *)) {
            [FritzCore configure];
            FritzVisionLabelModel *visionModel = [FritzVisionLabelModel new];
            FritzVisionImage *visionImage = [[FritzVisionImage alloc] initWithImage:image];
            [visionModel predict:visionImage options:nil completion:^(NSArray *objects, NSError *error) {
                @try {
                    if (error != nil || objects == nil) {
                        NSString *errorString = error ? error.localizedDescription : detectionNoResultsMessage;
                        @throw [NSException exceptionWithName:@"failure" reason:errorString userInfo:nil];
                        return;
                    }
                    RCTLog(@"Here we are");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        resolve(objects);
                    });
                }
                @catch (NSException *e) {
                    NSString *errorString = e ? e.reason : detectionNoResultsMessage;
                    NSDictionary *pData = @{
                                            @"error": [NSMutableString stringWithFormat:@"On-Device text detection failed with error: %@", errorString],
                                            };
                    dispatch_async(dispatch_get_main_queue(), ^{
                        resolve(pData);
                    });
                }
            }];
        } else {
            resolve(@NO);
            return;
        }

    });
    
}

    
@end
  
