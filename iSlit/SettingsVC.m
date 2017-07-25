//
//  SettingsVC.m
//  iSlit
//
//  Created by Михаил Луцкий on 23.07.17.
//  Copyright © 2017 BigBadBird.ru. All rights reserved.
//

#import "SettingsVC.h"
#import "Settings.h"
#import "CameraManager.h"

@interface SettingsVC () <MFMailComposeViewControllerDelegate> {
    Settings *settings;
    CameraManager *camera;
}

@end

@implementation SettingsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    settings = [[Settings alloc] init];
    camera = [CameraManager sharedManager];
    [self initialize];
}

- (void) initialize {
    _torchSwitch.on = [settings getTorchState];
    _autoFocusSwitch.on = [settings getAutoFocusState];
    if ([settings pixelCount] == 0) {
        [settings setPixelCount:1];
    }
    _pixelLabel.text = [NSString stringWithFormat:@"%li", (long)[settings pixelCount]];
    _plusStepper.value = [settings pixelCount];
    _typeSegment.selectedSegmentIndex = [settings typeOfRecord];
    switch ([settings fps]) {
        case FPS_30:
            _fpsSegment.selectedSegmentIndex = 0;
            break;
        case FPS_60:
            _fpsSegment.selectedSegmentIndex = 1;
            break;
        case FPS_120:
            _fpsSegment.selectedSegmentIndex = 2;
            break;
        case FPS_240:
            _fpsSegment.selectedSegmentIndex = 3;
            break;
        default:
            _fpsSegment.selectedSegmentIndex = 0;
            [settings setFps:FPS_30];
            [camera switchFormatWithDesiredFPS:FPS_30];
            break;
    }
}

- (IBAction)closeAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)torchAction:(id)sender {
    [settings setTorchState:[sender isOn]];
    [camera toggleFlash:[sender isOn]];
}

- (IBAction)autoFocusAction:(id)sender {
    [settings setAutoFocusState:[sender isOn]];
}

- (IBAction)plusAction:(id)sender {
    [settings setPixelCount:[(UIStepper*)sender value]];
    _pixelLabel.text = [NSString stringWithFormat:@"%li", (long)[settings pixelCount]];
}

- (IBAction)typeRecordChenge:(id)sender {
    [settings setTypeOfRecord:(RecordType)[sender selectedSegmentIndex]];
}

- (IBAction)supportAction:(id)sender {
    NSString *emailTitle = NSLocalizedString(@"Сообщение из iSlit", nil);
    NSString *messageBody = NSLocalizedString(@"\n\nОтправлено из приложения iSlit для iOS", nil);
    NSArray *toRecipents = [NSArray arrayWithObject:@"support@lwts.ru"];
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];
    [mc setToRecipients:toRecipents];
    
    [self presentViewController:mc animated:YES completion:NULL];
}

- (IBAction)changeFPS:(id)sender {
    switch ([sender selectedSegmentIndex]) {
        case 0:
            [settings setFps:FPS_30];
            [camera switchFormatWithDesiredFPS:FPS_30];
            break;
        case 1:
            [settings setFps:FPS_60];
            [camera switchFormatWithDesiredFPS:FPS_60];
            break;
        case 2:
            [settings setFps:FPS_120];
            [camera switchFormatWithDesiredFPS:FPS_120];
            break;
        case 3:
            [settings setFps:FPS_240];
            [camera switchFormatWithDesiredFPS:FPS_240];
            break;
        default:
            [settings setFps:FPS_30];
            [camera switchFormatWithDesiredFPS:FPS_30];
            break;
    }
}

-(void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    switch (result) {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
