//
//  CameraManager.h
//  iSlit
//
//  Created by Михаил Луцкий on 24.07.17.
//  Copyright © 2017 BigBadBird.ru. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

typedef enum {
    AutoFocusDisable = 0,
    AutoFocusEnable = 1
} AutoFocusState;

@interface CameraManager : NSObject

+ (instancetype) sharedManager;

- (void) start;

- (void) showVideoPreviewForView:(UIView *) view;

- (void) switchFormatWithDesiredFPS:(CGFloat)desiredFPS;

- (void) setAutoFocus:(AutoFocusState) state;

- (void) toggleFlash:(BOOL) state;

- (void) changeVideoPreset:(NSString *) preset;

@property AVCaptureDevice *videoDevice;
@property AVCaptureSession *captureSession;
@property dispatch_queue_t captureSessionQueue;
@property UIView* view;
@property (assign, nonatomic) id<AVCaptureVideoDataOutputSampleBufferDelegate> captureDelegate;

@end
