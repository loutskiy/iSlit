//
//  ViewController.m
//  RealtimeVideoFilter
//
//  Created by Altitude Labs on 23/12/15.
//  Copyright © 2015 BigBadBird.ru. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "UIImageViewAligned.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "SettingsVC.h"
#import "Settings.h"

typedef enum {
    AutoFocusDisable = 0,
    AutoFocusEnable = 1
} AutoFocusState;

@interface ViewController () <AVCaptureVideoDataOutputSampleBufferDelegate, SettingsChangeDelegate> {
    int countFrames;
    BOOL isRecording;
    Settings *settings;
}

@property AVCaptureDevice *videoDevice;
@property AVCaptureSession *captureSession;
@property dispatch_queue_t captureSessionQueue;
@property UIImageViewAligned *slitScanImageView;
@property UIButton *startRecording;
@property UIButton *saveButton;
@property UIButton *cancelButton;
@property UIButton *settingButton;
@property UIView *scanLine;
@property UIView *placeholder;
@property UIView *centerLine;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    settings = [[Settings alloc] init];
    
    if ([[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count] > 0)
    {
        _captureSession = [[AVCaptureSession alloc] init];
        [self _start];
    }
    else
    {
        NSLog(@"No device with AVMediaTypeVideo");
    }
    [self initialize];
}

- (void) initialize {
    self.view.backgroundColor = [UIColor clearColor];
    isRecording = FALSE;
    [self setupPlaceholder];
    [self setupSlitScanImageView];
    [self setupScanLine];
    [self setupStartRecording];
    [self setupSaveButton];
    [self setupSettingButton];
}

- (void) setupSlitScanImageView {
    _slitScanImageView = [[UIImageViewAligned alloc] initWithFrame:CGRectMake(0, 0, 1, self.view.frame.size.height)];
    _slitScanImageView.backgroundColor = [UIColor clearColor];
    _slitScanImageView.contentMode = UIViewContentModeScaleAspectFit;
    _slitScanImageView.alignLeft = YES;
    _slitScanImageView.clipsToBounds = YES;
    [self.view addSubview:_slitScanImageView];
}

- (void) setupScanLine {
    _scanLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, self.view.frame.size.height)];
    _scanLine.backgroundColor = [UIColor redColor];
    [self.view addSubview:_scanLine];
}

- (void) setupStartRecording {
    _startRecording = [[UIButton alloc] initWithFrame:CGRectMake(15, (self.view.frame.size.height / 2) - 30, 60, 60)];
    _startRecording.backgroundColor = [UIColor clearColor];
    [_startRecording setImage:[UIImage imageNamed:@"Camera"] forState:UIControlStateNormal];
    [_startRecording addTarget:self action:@selector(startRecording:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_startRecording];
}

- (void) setupSaveButton {
    _saveButton = [[UIButton alloc] initWithFrame:CGRectMake(15, (self.view.frame.size.height / 2) - 30, 60, 60)];
    _saveButton.backgroundColor = [UIColor clearColor];
    [_saveButton setImage:[UIImage imageNamed:@"Complete"] forState:UIControlStateNormal];
    [_saveButton addTarget:self action:@selector(saveButton:) forControlEvents:UIControlEventTouchUpInside];
    [_saveButton setHidden:YES];
    [self.view addSubview:_saveButton];
}

- (void) setupSettingButton {
    _settingButton = [[UIButton alloc] initWithFrame:CGRectMake(25, ((self.view.frame.size.height / 2) - 30) - 75, 40, 40)];
    _settingButton.backgroundColor = [UIColor clearColor];
    [_settingButton setImage:[UIImage imageNamed:@"settings"] forState:UIControlStateNormal];
    [_settingButton addTarget:self action:@selector(openSettings:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_settingButton];
}

- (void) setupPlaceholder {
    _placeholder = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 90, self.view.frame.size.height)];
    _placeholder.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    [self.view addSubview:_placeholder];
}

- (void) setupVideoPreview {
    
    AVCaptureVideoPreviewLayer *avLayer =
    [AVCaptureVideoPreviewLayer layerWithSession:_captureSession];
    avLayer.frame = self.view.frame;
    
    AVCaptureConnection *previewLayerConnection=avLayer.connection;
    
    if ([previewLayerConnection isVideoOrientationSupported])
        [previewLayerConnection setVideoOrientation:AVCaptureVideoOrientationLandscapeLeft];
    
    [self.view.layer addSublayer:avLayer];
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
    
    [self switchFormatWithDesiredFPS:60];
    
    NSDictionary *outputSettings = @{ (id)kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithInteger:kCVPixelFormatType_32BGRA]};
    AVCaptureVideoDataOutput *videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    videoDataOutput.videoSettings = outputSettings;
    _captureSessionQueue = dispatch_queue_create("capture_session_queue", NULL);
    [videoDataOutput setSampleBufferDelegate:self queue:_captureSessionQueue];
    videoDataOutput.alwaysDiscardsLateVideoFrames = YES;
    [self setupVideoPreview];
    
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

- (void)switchFormatWithDesiredFPS:(CGFloat)desiredFPS
{
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
                if ([videoDevice lockForConfiguration:nil]) {
                    NSLog(@"selected format:%@", format);
                    videoDevice.activeFormat = format;
                    videoDevice.activeVideoMinFrameDuration = CMTimeMake(1, (int32_t)desiredFPS);
                    videoDevice.activeVideoMaxFrameDuration = CMTimeMake(1, (int32_t)desiredFPS);
                    [videoDevice unlockForConfiguration];
                }
            }
        }
    }
    if (isRunning) [_captureSession startRunning];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    if (isRecording) {
        if ([connection isVideoOrientationSupported])
        {
            [connection setVideoOrientation:AVCaptureVideoOrientationLandscapeLeft];
        }
        
        CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        size_t width = CVPixelBufferGetWidth(imageBuffer);
        UIImage *cropImage = [self getCropImageFromImageBuffer:imageBuffer];

        dispatch_sync(dispatch_get_main_queue(), ^(){
            UIImage *newImage = [self compositeImage:_slitScanImageView.image withImage:cropImage];
            NSLog(@"newImage %f", _slitScanImageView.image.size.width);
            _slitScanImageView.image = newImage;
            _slitScanImageView.frame = CGRectMake(0, 0, _slitScanImageView.frame.size.width+1, _slitScanImageView.frame.size.height);
            CGRect frame = [self getFrameSizeForImage:newImage inImageView:_slitScanImageView];
            CGRect imageViewFrame = CGRectMake(_slitScanImageView.frame.origin.x + frame.origin.x-1, _slitScanImageView.frame.origin.y + frame.origin.y, frame.size.width, frame.size.height);
            _slitScanImageView.frame = imageViewFrame;
            _scanLine.frame = CGRectMake(_slitScanImageView.frame.size.width, 0, 1, _scanLine.frame.size.height);
            if (countFrames == width) {
                [self setAutoFocus:AutoFocusEnable];
                [_captureSession stopRunning];
                [_saveButton setHidden:NO];
                [_placeholder setHidden:NO];
                isRecording = NO;
            }
            countFrames++;
        });
    }
}

- (UIImage *) getCropImageFromImageBuffer:(CVImageBufferRef) imageBuffer
{
    CVPixelBufferLockBaseAddress(imageBuffer,0);        // Lock the image buffer
    
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);   // Get information of the image
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef newContext = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGImageRef newImage = CGBitmapContextCreateImage(newContext);
    CGContextRelease(newContext);
    
    CGColorSpaceRelease(colorSpace);
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    CGImageRef cropImage = CGImageCreateWithImageInRect(newImage, CGRectMake(width / 2, 0, 1, height));
    CGImageRelease( newImage );
    UIImage *finalImage = [UIImage imageWithCGImage:cropImage];
    CGImageRelease( cropImage );
    return finalImage;
}

- (UIImage*)compositeImage:(UIImage*)firstImage withImage:(UIImage*)secondImage {
    CGSize size = CGSizeMake(firstImage.size.width + secondImage.size.width, MAX(firstImage.size.height, secondImage.size.height));
    
    UIGraphicsBeginImageContext(size);
    
    [firstImage drawInRect:CGRectMake(0,0,firstImage.size.width, size.height)];
    [secondImage drawInRect:CGRectMake(firstImage.size.width, 0,secondImage.size.width, size.height)];
    
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return finalImage;
}

- (CGRect)getFrameSizeForImage:(UIImage *)image inImageView:(UIImageView *)imageView {
    
    float hfactor = image.size.width / imageView.frame.size.width;
    float vfactor = image.size.height / imageView.frame.size.height;
    
    float factor = fmax(hfactor, vfactor);
    
    float newWidth = image.size.width / factor;
    float newHeight = image.size.height / factor;
    
    float leftOffset = (imageView.frame.size.width - newWidth) / 2;
    float topOffset = (imageView.frame.size.height - newHeight) / 2;
    
    return CGRectMake(leftOffset, topOffset, newWidth, newHeight);
}

- (IBAction)startRecording:(id)sender {
    countFrames = 0;
    [self setAutoFocus:AutoFocusDisable];
    
    isRecording = YES;
    [_startRecording setHidden:YES];
    [_settingButton setHidden:YES];
    [_placeholder setHidden:YES];
}

- (IBAction)saveButton:(id)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    UIImageWriteToSavedPhotosAlbum(_slitScanImageView.image, self, @selector(photoSave:didFinishSavingWithError:contextInfo:), nil);
}

- (void)photoSave:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    [self hudComplete];
    _slitScanImageView.image = nil;
    [_saveButton setHidden:YES];
    [_startRecording setHidden:NO];
    [_settingButton setHidden:NO];
    _slitScanImageView.frame = CGRectMake(0, 0, 1, self.view.frame.size.height);
    _scanLine.frame = CGRectMake(0, 0, 1, self.view.frame.size.height);
    [_captureSession startRunning];
}

- (void) hudComplete {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeCustomView;
    UIImage *imageMark = [[UIImage imageNamed:@"Checkmark"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    hud.customView = [[UIImageView alloc] initWithImage:imageMark];
    hud.square = YES;
    hud.label.text = NSLocalizedString(@"Готово", @"HUD done title");
    
    [hud hideAnimated:YES afterDelay:3.f];
}

- (IBAction)openSettings:(id)sender {
    SettingsVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingsNav"];
    vc.delegate = self;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void) setAutoFocus:(AutoFocusState) state {
    AVCaptureDevice *device = _videoDevice;
    [device lockForConfiguration:nil];
    
    NSArray *devices = [AVCaptureDevice devices];
    NSError *error;
    for (AVCaptureDevice *device in devices) {
        if (([device hasMediaType:AVMediaTypeVideo]) &&
            ([device position] == AVCaptureDevicePositionBack) ) {
            [device lockForConfiguration:&error];
            if ([device isFocusModeSupported:AVCaptureFocusModeLocked]) {
                if (state == AutoFocusDisable) device.focusMode = AVCaptureFocusModeLocked;
                else device.focusMode = AVCaptureFocusModeContinuousAutoFocus;
                NSLog(@"Focus locked");
            }
            
            [device unlockForConfiguration];
        }
    }
}

- (void) toggleFlash:(BOOL) state {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasTorch] && [device hasFlash]){
        [device lockForConfiguration:nil];
        [device setTorchMode:state];
        [device setFlashMode:state];
        [device unlockForConfiguration];
    }
}

- (void)didFinishChangeSettings {
    NSLog(@"change");
    [self switchFormatWithDesiredFPS:[settings fps]];
    [self setAutoFocus:[settings getAutoFocusState]];
    [self toggleFlash:[settings getTorchState]];
}

@end
