//
//  ViewController.h
//  RealtimeVideoFilter
//
//  Created by Altitude Labs on 23/12/15.
//  Copyright © 2015 BigBadBird.ru. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageViewAligned.h"
#import <AVFoundation/AVFoundation.h>
#import "SettingsVC.h"
#import "Settings.h"
#import "CameraManager.h"
#import "ImageManager.h"
#import "HUDManager.h"

@interface ViewController : UIViewController {
    int countFrames;
    BOOL isRecording;
    Settings *settings;
    CameraManager *camera;
}

@property UIImageViewAligned *slitScanImageView;
@property UIButton *startRecording;
@property UIButton *saveButton;
@property UIButton *cancelButton;
@property UIButton *settingButton;
@property UIButton *trashButton;
@property UIView *scanLine;
@property UIView *placeholder;
@property UIView *centerLine;

@end

