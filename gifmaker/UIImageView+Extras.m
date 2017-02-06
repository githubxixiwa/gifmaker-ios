//
//  UIImageView+Extras.m
//  gifmaker
//
//  Created by Sergii Simakhin on 2/6/17.
//  Copyright © 2017 Cayugasoft. All rights reserved.
//

#import "UIImageView+Extras.h"

@implementation UIImageView (Extras)

#pragma mark - Helpers

// Method to set image and check in runtime is it rotated (to rotate to normal orientation before setting in UIImageView)
- (void)setImageWithCheckingOrientation:(UIImage *)image orientation:(UIInterfaceOrientation)orientation {
    // Check if image is rotated
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        [self setImage:[UIImage imageWithCGImage:image.CGImage scale:1.0f orientation:UIImageOrientationRight]];
    } else {
        [self setImage:image];
    }
}

@end
