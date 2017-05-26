//
//  UIImageView+Extras.m
//  gifmaker
//
//  Created by Sergii Simakhin on 5/16/17.
//  Copyright © 2017 Cayugasoft. All rights reserved.
//

// Models
#import "UIImageView+Extras.h"

@implementation UIImageView (Extras)

- (void)applyTriangleMask {
    UIBezierPath *trianglePath = [UIBezierPath bezierPath];
    [trianglePath moveToPoint:CGPointMake(0, self.frame.size.height)];
    [trianglePath addLineToPoint:CGPointMake(self.frame.size.width, 0)];
    [trianglePath addLineToPoint:CGPointMake(self.frame.size.width, self.frame.size.height)];
    [trianglePath closePath];
    
    CAShapeLayer *triangleMask = [CAShapeLayer layer];
    [triangleMask setPath:trianglePath.CGPath];
    
    self.layer.mask = triangleMask;
}

@end
