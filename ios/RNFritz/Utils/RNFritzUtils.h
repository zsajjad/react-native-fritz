//
//  RNFritzUtils.h
//  RNFritz
//
//  Created by Zain Sajjad on 22/01/2019.
//

#ifndef RNFritzUtils_h
#define RNFritzUtils_h
@import FritzVision;

@interface RNFritzUtils : NSObject 

+ (FritzVisionImage *) getFritzVisionImage: (NSString *)imagePath;
+ (NSError *) errorFromException: (NSException *)exception;
+ (UIImage *) getUIImage: (NSString *)imagePath;

@end

#endif /* RNFritzUtils_h */
