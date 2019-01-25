//
//  FritzCustomModel.m
//  RNFritz
//
//  Created by Zain Sajjad on 23/01/2019.
//
// CarRecognition+Fritz.m
#import "FritzCustomModel.h"
#import <React/RCTLog.h>

@implementation FritzCustomModel
+ (NSString * _Nonnull)fritzModelIdentifier {
    RCTLog([[NSBundle mainBundle] objectForInfoDictionaryKey:@"FritzModelId"]);
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"FritzModelId"];
}

+ (FritzSession *)fritzSession {
    static FritzSession *session = nil;
    static dispatch_once_t token;
    
    RCTLog([[NSBundle mainBundle] objectForInfoDictionaryKey:@"FritzAppToken"]);
    dispatch_once(&token, ^{
        session = [[FritzSession alloc] initWithAppToken:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"FritzAppToken"]];
    });
    return session;
}

+ (NSInteger)fritzPackagedModelVersion {
//    return [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"FritzModelVersion"] integerValue];
    return 1;
}

@end
