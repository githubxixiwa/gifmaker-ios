//
//  UIImage+Extras.h
//  gifmaker
//
//  Created by Sergii Simakhin on 11/25/15.
//  Copyright © 2015 Cayugasoft. All rights reserved.
//

// Frameworks
#import <UIKit/UIKit.h>

// Models
#import "GifQuality.h"

@interface UIImage (Extras)

+ (UIImage *)imageByCroppingCGImage:(CGImageRef)cgImage toSize:(CGSize)size;
+ (UIImage *)imageByCroppingVideoFrameCGImage:(CGImageRef)cgImage toSize:(CGSize)size;

- (UIImage *)drawHeaderText:(NSString *)headerText
                 footerText:(NSString *)footerText
   withAttributesDictionary:(NSDictionary *)textAttributesDictionary
                 forQuality:(GifQuality)quality;

@end
