//
//  SettingsVC.h
//  iSlit
//
//  Created by Михаил Луцкий on 23.07.17.
//  Copyright © 2017 BigBadBird.ru. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SettingsChangeDelegate;

@interface SettingsVC : UITableViewController
- (IBAction)closeAction:(id)sender;
@property (weak, nonatomic) IBOutlet UISegmentedControl *fpsSegment;
@property (weak, nonatomic) IBOutlet UISegmentedControl *resolutionsSegment;
@property (weak, nonatomic) IBOutlet UISegmentedControl *typeSegment;
@property (weak, nonatomic) IBOutlet UIStepper *plusStepper;
@property (weak, nonatomic) IBOutlet UISwitch *autoFocusSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *torchSwitch;
@property (weak, nonatomic) IBOutlet UILabel *pixelLabel;
@property (assign, nonatomic) id <SettingsChangeDelegate> delegate;
- (IBAction)torchAction:(id)sender;
- (IBAction)autoFocusAction:(id)sender;
- (IBAction)plusAction:(id)sender;

@end


@protocol SettingsChangeDelegate

- (void) didFinishChangeSettings;

@end
