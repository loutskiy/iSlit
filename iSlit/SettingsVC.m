//
//  SettingsVC.m
//  iSlit
//
//  Created by Михаил Луцкий on 23.07.17.
//  Copyright © 2017 BigBadBird.ru. All rights reserved.
//

#import "SettingsVC.h"
#import "Settings.h"

@interface SettingsVC () {
    Settings *settings;
}

@end

@implementation SettingsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    settings = [[Settings alloc] init];
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
    
}

- (IBAction)closeAction:(id)sender {
    NSLog(@"111");
    [self.delegate didFinishChangeSettings];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)torchAction:(id)sender {
    [settings setTorchState:[sender isOn]];
}

- (IBAction)autoFocusAction:(id)sender {
    [settings setAutoFocusState:[sender isOn]];
}

- (IBAction)plusAction:(id)sender {
    [settings setPixelCount:[(UIStepper*)sender value]];
    _pixelLabel.text = [NSString stringWithFormat:@"%li", (long)[settings pixelCount]];
}
@end
