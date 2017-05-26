//
//  NSDictionary+Extras.m
//  gifmaker
//
//  Created by Sergii Simakhin on 4/19/17.
//  Copyright © 2017 Cayugasoft. All rights reserved.
//

// Frameworks
#import <UIKit/UIKit.h>

// Models
#import "NSDictionary+Extras.h"

// Helpers
#import "Macros.h"

@implementation NSDictionary (Extras)

+ (NSDictionary *)fontAttributesDictionaryWithDefaultFontSize {
    return [self fontAttributesDictionaryWithSize:CAPTIONS_FONT_SIZE];
}

+ (NSDictionary *)fontAttributesDictionaryBasedOnImageSize:(CGSize)imageSize containerSize:(CGSize)containerSize {
    NSInteger realFontSize = (CAPTIONS_FONT_SIZE * (imageSize.width / containerSize.width)) + 1;
    return [self fontAttributesDictionaryWithSize:realFontSize];
}

+ (NSDictionary *)fontAttributesDictionaryWithSize:(NSInteger)fontSize {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributesDictionary = @{
                                           NSStrokeColorAttributeName: [UIColor blackColor],
                                           NSForegroundColorAttributeName: [UIColor whiteColor],
                                           NSParagraphStyleAttributeName: paragraphStyle,
                                           NSStrokeWidthAttributeName: @(-4.0),
                                           NSFontAttributeName: [UIFont fontWithName:@"Impact" size:fontSize]
                                           };
    return attributesDictionary;
}

@end
