//
//  UIImage+Extras.h
//  gifmaker
//
//  Created by Sergio on 11/25/15.
//  Copyright © 2015 Cayugasoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Extras)

+ (UIImage *)imageByCroppingCGImage:(CGImageRef)cgImage toSize:(CGSize)size;
+ (UIImage *)imageByCroppingVideoFrameCGImage:(CGImageRef)cgImage toSize:(CGSize)size;

@end
