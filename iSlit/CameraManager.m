//
//  CameraManager.m
//  iSlit
//
//  Created by Михаил Луцкий on 24.07.17.
//  Copyright © 2017 BigBadBird.ru. All rights reserved.
//

#import "CameraManager.h"

@implementation CameraManager

+ (instancetype)sharedManager {
    static CameraManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (void)start {
    if ([[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count] > 0)
    {
        _captureSession = [[AVCaptureSession alloc] init];
        [self _start];
    }
    else
    {
        NSLog(@"No device with AVMediaTypeVideo");
    }
}

- (void)_start
{
    [self setVideoDevice];
    
    [_captureSession beginConfiguration];
    
    NSError *error = nil;
    AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:_videoDevice error:&error];
    [_captureSession addInput:videoDeviceInput];
    if (!videoDeviceInput)
    {
        NSLog(@"%@", [NSString stringWithFormat:@"Unable to obtain video device input, error: %@", error]);
        return;
    }

        
    NSDictionary *outputSettings = @{ (id)kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithInteger:kCVPixelFormatType_32BGRA]};
    AVCaptureVideoDataOutput *videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    videoDataOutput.videoSettings = outputSettings;
    _captureSessionQueue = dispatch_queue_create("capture_session_queue", NULL);
    [videoDataOutput setSampleBufferDelegate:_captureDelegate queue:_captureSessionQueue];
    videoDataOutput.alwaysDiscardsLateVideoFrames = YES;
    
    if (![_captureSession canAddOutput:videoDataOutput])
    {
        NSLog(@"Cannot add video data output");
        _captureSession = nil;
        return;
    }
    [_captureSession addOutput:videoDataOutput];
    [_captureSession commitConfiguration];
    [_captureSession startRunning];
}

- (void)showVideoPreviewForView:(UIView *)view {
    AVCaptureVideoPreviewLayer *avLayer =
    [AVCaptureVideoPreviewLayer layerWithSession:_captureSession];
    avLayer.frame = view.frame;
    
    AVCaptureConnection *previewLayerConnection=avLayer.connection;
    
    if ([previewLayerConnection isVideoOrientationSupported])
        [previewLayerConnection setVideoOrientation:AVCaptureVideoOrientationLandscapeLeft];
    
    [view.layer addSublayer:avLayer];
}

- (void) setVideoDevice {
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDevicePosition position = AVCaptureDevicePositionBack;
    for (AVCaptureDevice *device in videoDevices)
    {
        if (device.position == position) {
            _videoDevice = device;
            break;
        }
    }
}

- (void)switchFormatWithDesiredFPS:(CGFloat)desiredFPS {
    BOOL isRunning = _captureSession.isRunning;
    if (isRunning) [_captureSession stopRunning];
    AVCaptureDevice *videoDevice = _videoDevice;
    int32_t maxWidth = 0;
    for (AVCaptureDeviceFormat *format in [videoDevice formats]) {
        for (AVFrameRateRange *range in format.videoSupportedFrameRateRanges) {
            CMFormatDescriptionRef desc = format.formatDescription;
            CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions(desc);
            int32_t width = dimensions.width;
            if (range.minFrameRate <= desiredFPS && desiredFPS <= range.maxFrameRate && width >= maxWidth)
            {
                maxWidth = width;
                [videoDevice lockForConfiguration:nil];
//                NSLog(@"selected format:%@", format);
                videoDevice.activeFormat = format;
                videoDevice.activeVideoMinFrameDuration = CMTimeMake(1, (int32_t)desiredFPS);
                videoDevice.activeVideoMaxFrameDuration = CMTimeMake(1, (int32_t)desiredFPS);
                [videoDevice unlockForConfiguration];
            }
        }
    }
    if (isRunning) [_captureSession startRunning];
}

- (void) setAutoFocus:(AutoFocusState) state {
    AVCaptureDevice *device = _videoDevice;
    if ([device isFocusModeSupported:AVCaptureFocusModeLocked]) {
        [device lockForConfiguration:nil];
        if (state == AutoFocusDisable) device.focusMode = AVCaptureFocusModeLocked;
        else device.focusMode = AVCaptureFocusModeContinuousAutoFocus;
        [device unlockForConfiguration];
    }
}

- (void) toggleFlash:(BOOL) state {
    AVCaptureDevice *device = _videoDevice;
    if ([device hasTorch] && [device hasFlash]){
        [device lockForConfiguration:nil];
        [device setTorchMode:state];
        [device setFlashMode:state];
        [device unlockForConfiguration];
    }
}

- (void)changeVideoPreset:(NSString *)preset {
    if (![_videoDevice supportsAVCaptureSessionPreset:preset])
    {
        NSLog(@"%@", [NSString stringWithFormat:@"Capture session preset not supported by video device: %@", preset]);
        return;
    }
    _captureSession.sessionPreset = preset;
}

@end
