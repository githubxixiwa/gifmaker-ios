//
//  Filter.h
//  gifmaker
//
//  Created by Sergii Simakhin on 3/2/17.
//  Copyright © 2017 Cayugasoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface Filter : NSObject <NSCoding>

@property (nonatomic, strong) NSString *title;

/**
 CIFilter string representation. Look more: https://developer.apple.com/library/content/documentation/GraphicsImaging/Reference/CoreImageFilterReference/#//apple_ref/doc/filter/
 */
@property (nonatomic, strong) NSString *ciFilterTitle;
@property (nonatomic) CGFloat ciFilterIntensivity;

/**
 Returns a filter that will apply to GIF (UIImage is also supported)

 @param title user visible filter title
 @param ciFilterTitle CIFilter name
 @return filter object
 */
- (instancetype)initWithTitle:(NSString *)title ciFilterTitle:(NSString *)ciFilterTitle;

/**
 Returns a filter that will apply to GIF (UIImage is also supported)

 @param title user visible filter title
 @param ciFilterTitle CIFilter name
 @param filterIntensivity filter intensivity in range from 0.0 to 1.0 (intensivity will be ignored if value is lower than 0)
 @return filter object
 */
- (instancetype)initWithTitle:(NSString *)title ciFilterTitle:(NSString *)ciFilterTitle ciFilterIntensivity:(CGFloat)filterIntensivity;

/**
 Determine is filter normal or not (by normal means not a filter, just unmodified normal state of image)

 @return YES or NO
 */
- (BOOL)isNormal;

@end
