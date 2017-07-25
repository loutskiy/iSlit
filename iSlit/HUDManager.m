//
//  HUDManager.m
//  iSlit
//
//  Created by Михаил Луцкий on 24.07.17.
//  Copyright © 2017 BigBadBird.ru. All rights reserved.
//

#import "HUDManager.h"

@implementation HUDManager

+ (void)showHUDLoadingForView:(UIView *)view {
    [MBProgressHUD showHUDAddedTo:view animated:YES];
}

+ (void)showHUDCompleteForView:(UIView *)view {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeCustomView;
    UIImage *imageMark = [[UIImage imageNamed:@"Checkmark"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    hud.customView = [[UIImageView alloc] initWithImage:imageMark];
    hud.square = YES;
    hud.label.text = NSLocalizedString(@"Готово", @"HUD done title");
    [hud hideAnimated:YES afterDelay:3.f];
}

+ (void)hideHUDLoadingForView:(UIView *)view {
    [MBProgressHUD hideHUDForView:view animated:YES];
}

@end
