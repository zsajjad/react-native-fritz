//
//  RNFritzUtils.m
//  RNFritz
//
//  Created by Zain Sajjad on 22/01/2019.
//

#import <Foundation/Foundation.h>

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
                                    @"callStackReturnAddresses": exception.callStackReturnAddresses,
                                    @"callStackSymbols": exception.callStackSymbols,
                                    @"userInfo": exception.userInfo
                                    };
    return [[NSError alloc] initWithDomain: @"RNFritz"
                                      code: 0
                                  userInfo: exceptionInfo];
}

@end
