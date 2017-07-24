//
//  Settings.h
//  iSlit
//
//  Created by Михаил Луцкий on 23.07.17.
//  Copyright © 2017 BigBadBird.ru. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    FPS_30 = 30,
    FPS_60 = 60,
    FPS_120 = 120,
    FPS_240 = 240
} FPS;

typedef enum {
    _720p = 0,
    _1080p,
    _4K
} Resolutions;

@interface Settings : NSObject {
    NSUserDefaults *ud;
}

@property (getter=getTorchState, setter=setTorchState:) BOOL isTorchEnable;
@property (getter=getAutoFocusState, setter=setAutoFocusState:) BOOL isAutoFocusEnable;
@property NSString *quality;
@property FPS fps;
@property NSInteger pixelCount;

@end
