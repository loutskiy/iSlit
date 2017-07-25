//
//  Settings.m
//  iSlit
//
//  Created by Михаил Луцкий on 23.07.17.
//  Copyright © 2017 BigBadBird.ru. All rights reserved.
//

#import "Settings.h"

@implementation Settings

- (instancetype)init {
    self = [super init];
    if (self) {
        ud = [NSUserDefaults standardUserDefaults];
        if (![ud integerForKey:@"fps"] || [ud integerForKey:@"fps"] == 0) {
            [ud setInteger:FPS_30 forKey:@"fps"];
        }
    }
    return self;
}

- (void)setFps:(FPS)fps {
    [ud setObject:@(fps) forKey:@"fps"];
}

- (FPS)fps {
    return (FPS)[ud integerForKey:@"fps"];
}

- (BOOL)getTorchState {
    return [ud boolForKey:@"torch"];
}

- (void)setTorchState:(BOOL)isTorchEnable {
    [ud setBool:isTorchEnable forKey:@"torch"];
}

- (BOOL)getAutoFocusState {
    return [ud boolForKey:@"autofocus"];
}

- (void)setAutoFocusState:(BOOL)isAutoFocusEnable {
    [ud setBool:isAutoFocusEnable forKey:@"autofocus"];
}

- (void)setPixelCount:(int)pixelCount {
    [ud setInteger:pixelCount forKey:@"pixelcount"];
}

- (int)pixelCount {
    return (int)[ud integerForKey:@"pixelcount"];
}

- (void)setTypeOfRecord:(RecordType)typeOfRecord {
    [ud setBool:typeOfRecord forKey:@"typeOfRecord"];
}

- (RecordType)typeOfRecord {
    return [ud boolForKey:@"typeOfRecord"];
}

@end
