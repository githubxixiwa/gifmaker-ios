//
//  UIImage+Extras.m
//  gifmaker
//
//  Created by Sergii Simakhin on 11/25/15.
//  Copyright © 2015 Cayugasoft. All rights reserved.
//

// Models
#import "UIImage+Extras.h"

// Helpers
#import "Macros.h"

@implementation UIImage (Extras)

+ (UIImage *)imageByCroppingCGImage:(CGImageRef)cgImage toSize:(CGSize)size {
    double refWidth = CGImageGetWidth(cgImage);
    double refHeight = CGImageGetHeight(cgImage);
    
    double x = (refWidth - size.width) / 2.0;
    double y = (refHeight - size.height) / 2.0;
    
    CGRect cropRect = CGRectMake(x, y, size.height, size.width);
    CGImageRef imageRef = CGImageCreateWithImageInRect(cgImage, cropRect);
    
    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return cropped;
}

+ (UIImage *)imageByCroppingVideoFrameCGImage:(CGImageRef)cgImage toSize:(CGSize)size {
    double width = CGImageGetWidth(cgImage);
    double height = CGImageGetHeight(cgImage);
    double newCropWidth, newCropHeight;
    
    if (width < height) {
        if (width < size.width) {
            newCropWidth = size.width;
        } else {
            newCropWidth = width;
        }
        newCropHeight = (newCropWidth * size.height)/size.width;
    } else {
        if (height < size.height) {
            newCropHeight = size.height;
        } else {
            newCropHeight = height;
        }
        newCropWidth = (newCropHeight * size.width)/size.height;
    }
    
    double x = width / 2.0 - newCropWidth / 2.0;
    double y = height / 2.0 - newCropHeight / 2.0;
    
    CGRect cropRect = CGRectMake(x, y, newCropWidth, newCropHeight);
    CGImageRef croppedImageRef = CGImageCreateWithImageInRect(cgImage, cropRect);
    
    UIImage *croppedImage = [UIImage imageWithCGImage:croppedImageRef];
    CGImageRelease(croppedImageRef);
    
    UIGraphicsBeginImageContext(size);
    [croppedImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage* resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resizedImage;
}


#pragma mark - Captions drawer

- (UIImage *)drawHeaderText:(NSString *)headerText
                 footerText:(NSString *)footerText
   withAttributesDictionary:(NSDictionary *)textAttributesDictionary
                 forQuality:(GifQuality)quality {
    
    CGFloat sideSize = GifSideSizeFromQuality(quality);
    
    UIGraphicsBeginImageContext(CGSizeMake(sideSize, sideSize));
    
    // Draw image on context
    [self drawAtPoint:CGPointMake(0, 0)];
    
    // Get attributed text size
    CGSize headerTextSize = [headerText sizeWithAttributes:textAttributesDictionary];
    CGSize footerTextSize = [footerText sizeWithAttributes:textAttributesDictionary];
    
    NSInteger offset = 2;
    
    CGRect headerCaptionRect = CGRectMake(offset,
                                          offset * 2,
                                          sideSize - (offset * 2),
                                          headerTextSize.height);
    
    CGRect footerCaptionRect = CGRectMake(offset,
                                          sideSize - (offset * 2) - footerTextSize.height,
                                          sideSize - (offset * 2),
                                          footerTextSize.height);
    
    // Draw header and footer
    [headerText drawInRect:headerCaptionRect withAttributes:textAttributesDictionary];
    [footerText drawInRect:footerCaptionRect withAttributes:textAttributesDictionary];
    
    // Make image out of bitmap context
    UIImage *imageWithHeaderAndFooterText = UIGraphicsGetImageFromCurrentImageContext();
    
    // Free the context
    UIGraphicsEndImageContext();
    
    return imageWithHeaderAndFooterText;
}

@end
