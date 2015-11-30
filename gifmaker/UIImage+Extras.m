//
//  UIImage+Extras.m
//  gifmaker
//
//  Created by Sergio on 11/25/15.
//  Copyright © 2015 Cayugasoft. All rights reserved.
//

#import "UIImage+Extras.h"

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

@end
