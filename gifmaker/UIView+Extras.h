//
//  UIView+Extras.h
//  gifmaker
//
//  Created by Sergii Simakhin on 4/6/16.
//  Copyright © 2016 Cayugasoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Extras)

- (UIImage *)croppedImageForRect:(CGRect)cropRect;
- (void)applyShadow;

@end
