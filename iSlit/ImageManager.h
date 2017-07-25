//
//  ImageManager.h
//  iSlit
//
//  Created by Михаил Луцкий on 24.07.17.
//  Copyright © 2017 BigBadBird.ru. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Settings.h"

@interface ImageManager : NSObject

+ (UIImage*) slideType:(CVImageBufferRef) imageBuffer withPixel:(int) pixel;

+ (UIImage *) staticType:(CVImageBufferRef) imageBuffer withPixel:(int) pixel;

+ (UIImage*)compositeImage:(UIImage*)firstImage withImage:(UIImage*)secondImage;

+ (CGRect)getFrameSizeForImage:(UIImage *)image inImageView:(UIImageView *)imageView;

@end
