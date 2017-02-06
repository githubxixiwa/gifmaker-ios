//
//  UIView+Extras.m
//  gifmaker
//
//  Created by Sergio on 4/6/16.
//  Copyright © 2016 Cayugasoft. All rights reserved.
//

#import "UIView+Extras.h"

@implementation UIView (Extras)

- (UIImage *)croppedImageForRect:(CGRect)cropRect {
    UIGraphicsBeginImageContextWithOptions(cropRect.size, YES, 1.f);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(ctx, -cropRect.origin.x, -cropRect.origin.y);
    [self.layer renderInContext:ctx];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)snapshot:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0f);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
