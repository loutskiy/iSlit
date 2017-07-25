//
//  HUDManager.h
//  iSlit
//
//  Created by Михаил Луцкий on 24.07.17.
//  Copyright © 2017 BigBadBird.ru. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface HUDManager : NSObject

+ (void) showHUDLoadingForView:(UIView *) view;
+ (void) hideHUDLoadingForView:(UIView *) view;
+ (void) showHUDCompleteForView:(UIView *) view;

@end
