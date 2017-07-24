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
    }
    return self;
}

- (void)setFps:(FPS)fps {
    [ud setObject:@(fps) forKey:@"fps"];
}

- (FPS)fps {
    return (FPS)[ud valueForKey:@"fps"];
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

- (void)setPixelCount:(NSInteger)pixelCount {
    [ud setInteger:pixelCount forKey:@"pixelcount"];
}

- (NSInteger)pixelCount {
    return [ud integerForKey:@"pixelcount"];
}

@end
