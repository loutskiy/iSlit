//
//  SettingsVC.h
//  iSlit
//
//  Created by Михаил Луцкий on 23.07.17.
//  Copyright © 2017 BigBadBird.ru. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface SettingsVC : UITableViewController

- (IBAction)closeAction:(id)sender;
@property (weak, nonatomic) IBOutlet UISegmentedControl *fpsSegment;
@property (weak, nonatomic) IBOutlet UISegmentedControl *resolutionsSegment;
@property (weak, nonatomic) IBOutlet UISegmentedControl *typeSegment;
@property (weak, nonatomic) IBOutlet UIStepper *plusStepper;
@property (weak, nonatomic) IBOutlet UISwitch *autoFocusSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *torchSwitch;
@property (weak, nonatomic) IBOutlet UILabel *pixelLabel;
- (IBAction)torchAction:(id)sender;
- (IBAction)autoFocusAction:(id)sender;
- (IBAction)plusAction:(id)sender;
- (IBAction)typeRecordChenge:(id)sender;
- (IBAction)supportAction:(id)sender;
- (IBAction)changeFPS:(id)sender;

@end
