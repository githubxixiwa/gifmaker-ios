//
//  UIView+Extras.m
//  gifmaker
//
//  Created by Sergii Simakhin on 4/6/16.
//  Copyright © 2016 Cayugasoft. All rights reserved.
//

// Frameworks
#import <QuartzCore/QuartzCore.h>

// Models
#import "UIView+Extras.h"

@implementation UIView (Extras)

- (void)applyShadow {
    [self.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [self.layer setShadowOffset:CGSizeMake(6, 6)];
    [self.layer setShadowRadius:3.0];
    [self.layer setShadowOpacity:0.3];
}

- (UIImage *)screenshot {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0);
    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];
    UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return screenshot;
}

@end
