//
//  ViewController.m
//  RealtimeVideoFilter
//
//  Created by Altitude Labs on 23/12/15.
//  Copyright © 2015 BigBadBird.ru. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <AVCaptureVideoDataOutputSampleBufferDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    settings = [[Settings alloc] init];
    camera = [CameraManager sharedManager];
    [camera setCaptureDelegate:self];
    [camera start];
    [camera showVideoPreviewForView:self.view];
    [camera switchFormatWithDesiredFPS:[settings fps]];
    [camera toggleFlash:[settings getTorchState]];

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
    [self setupTrashButton];
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

- (void) setupTrashButton {
    _trashButton = [[UIButton alloc] initWithFrame:CGRectMake(25, ((self.view.frame.size.height / 2) - 30) - 75, 40, 40)];
    _trashButton.backgroundColor = [UIColor clearColor];
    [_trashButton setImage:[UIImage imageNamed:@"trash"] forState:UIControlStateNormal];
    [_trashButton addTarget:self action:@selector(trashAction:) forControlEvents:UIControlEventTouchUpInside];
    [_trashButton setHidden:YES];
    [self.view addSubview:_trashButton];
}

- (void) setupPlaceholder {
    _placeholder = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 90, self.view.frame.size.height)];
    _placeholder.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    [self.view addSubview:_placeholder];
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
        UIImage *cropImage = [settings typeOfRecord] ? [ImageManager staticType:imageBuffer withPixel:[settings pixelCount]] : [ImageManager slideType:imageBuffer withPixel:[settings pixelCount]];

        dispatch_sync(dispatch_get_main_queue(), ^(){
            UIImage *newImage = [ImageManager compositeImage:_slitScanImageView.image withImage:cropImage];
            NSLog(@"newImage %f", _slitScanImageView.image.size.width);
            _slitScanImageView.image = newImage;
            _slitScanImageView.frame = CGRectMake(0, 0, _slitScanImageView.frame.size.width+[settings pixelCount], _slitScanImageView.frame.size.height);
            CGRect frame = [ImageManager getFrameSizeForImage:newImage inImageView:_slitScanImageView];
            CGRect imageViewFrame = CGRectMake(_slitScanImageView.frame.origin.x + frame.origin.x-[settings pixelCount], _slitScanImageView.frame.origin.y + frame.origin.y, frame.size.width, frame.size.height);
            _slitScanImageView.frame = imageViewFrame;
            _scanLine.frame = CGRectMake(_slitScanImageView.frame.size.width, 0, 1, _scanLine.frame.size.height);
            if (countFrames >= width) {
                [camera setAutoFocus:AutoFocusEnable];
                [camera.captureSession stopRunning];
                [_saveButton setHidden:NO];
                [_trashButton setHidden:NO];
                [_placeholder setHidden:NO];
                isRecording = NO;
            }
            countFrames+=[settings pixelCount];
        });
    }
}

- (IBAction)startRecording:(id)sender {
    countFrames = 0;
    [camera setAutoFocus:[settings getAutoFocusState]];
    
    isRecording = YES;
    [_startRecording setHidden:YES];
    [_settingButton setHidden:YES];
    [_placeholder setHidden:YES];
}

- (IBAction)saveButton:(id)sender {
    [HUDManager showHUDLoadingForView:self.view];
    UIImageWriteToSavedPhotosAlbum(_slitScanImageView.image, self, @selector(photoSave:didFinishSavingWithError:contextInfo:), nil);
}

- (void)photoSave:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    [self hudComplete];
    [self refreshViews];
}

- (void) hudComplete {
    [HUDManager hideHUDLoadingForView:self.view];
    [HUDManager showHUDCompleteForView:self.view];
}

- (IBAction)openSettings:(id)sender {
    SettingsVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingsNav"];
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)trashAction:(id)sender {
    [self refreshViews];
}

- (void) refreshViews {
    _slitScanImageView.image = nil;
    [_saveButton setHidden:YES];
    [_startRecording setHidden:NO];
    [_settingButton setHidden:NO];
    [_trashButton setHidden:YES];
    _slitScanImageView.frame = CGRectMake(0, 0, 1, self.view.frame.size.height);
    _scanLine.frame = CGRectMake(0, 0, 1, self.view.frame.size.height);
    [camera.captureSession startRunning];
    [camera toggleFlash:[settings getTorchState]];
}

@end
