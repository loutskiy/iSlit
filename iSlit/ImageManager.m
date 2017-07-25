//
//  ImageManager.m
//  iSlit
//
//  Created by Михаил Луцкий on 24.07.17.
//  Copyright © 2017 BigBadBird.ru. All rights reserved.
//

#import "ImageManager.h"

@implementation ImageManager

+ (UIImage *) slideType:(CVImageBufferRef) imageBuffer withPixel:(int) pixel {
    static int count = 0;
    UIImage *result = [ImageManager getCropImageFromImageBuffer:imageBuffer numeric:&count type:SlideType withPixel:pixel];
    return result;
}

+ (UIImage *) staticType:(CVImageBufferRef) imageBuffer withPixel:(int) pixel {
    UIImage *result = [ImageManager getCropImageFromImageBuffer:imageBuffer numeric:0 type:StaticType withPixel:pixel];
    return result;
}

+ (UIImage *) getCropImageFromImageBuffer:(CVImageBufferRef) imageBuffer numeric:(int *) numeric type:(RecordType) type withPixel:(int) pixel {
    CVPixelBufferLockBaseAddress(imageBuffer,0);
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef newContext = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGImageRef newImage = CGBitmapContextCreateImage(newContext);
    CGContextRelease(newContext);
    CGColorSpaceRelease(colorSpace);
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    unsigned long x = 0;
    if (type == StaticType) {
        x = width / 2;
    } else if (type == SlideType) {
        x = *numeric;
    }
    CGImageRef cropImage = CGImageCreateWithImageInRect(newImage, CGRectMake(x, 0, pixel, height));
    if (type == SlideType) {
        if (*numeric >= width) {
            *numeric = 0;
        } else {
            *numeric = *numeric + pixel;
        }
    }
    CGImageRelease( newImage );
    UIImage *finalImage = [UIImage imageWithCGImage:cropImage];
    CGImageRelease( cropImage );
    return finalImage;
}

+ (UIImage*)compositeImage:(UIImage*)firstImage withImage:(UIImage*)secondImage {
    CGSize size = CGSizeMake(firstImage.size.width + secondImage.size.width, MAX(firstImage.size.height, secondImage.size.height));
    
    UIGraphicsBeginImageContext(size);
    
    [firstImage drawInRect:CGRectMake(0,0,firstImage.size.width, size.height)];
    [secondImage drawInRect:CGRectMake(firstImage.size.width, 0,secondImage.size.width, size.height)];
    
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return finalImage;
}

+ (CGRect)getFrameSizeForImage:(UIImage *)image inImageView:(UIImageView *)imageView {
    float hfactor = image.size.width / imageView.frame.size.width;
    float vfactor = image.size.height / imageView.frame.size.height;
    
    float factor = fmax(hfactor, vfactor);
    
    float newWidth = image.size.width / factor;
    float newHeight = image.size.height / factor;
    
    float leftOffset = (imageView.frame.size.width - newWidth) / 2;
    float topOffset = (imageView.frame.size.height - newHeight) / 2;
    
    return CGRectMake(leftOffset, topOffset, newWidth, newHeight);
}

@end
