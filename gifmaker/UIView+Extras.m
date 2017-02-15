//
//  UIView+Extras.m
//  gifmaker
//
//  Created by Sergii Simakhin on 4/6/16.
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

- (void)applyShadow {
    [self.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [self.layer setShadowOffset:CGSizeMake(6, 6)];
    [self.layer setShadowRadius:3.0];
    [self.layer setShadowOpacity:0.3];
}

@end
