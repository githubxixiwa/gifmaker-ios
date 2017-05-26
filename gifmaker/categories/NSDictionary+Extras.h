//
//  NSDictionary+Extras.h
//  gifmaker
//
//  Created by Sergii Simakhin on 4/19/17.
//  Copyright © 2017 Cayugasoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Extras)

/**
 Font attributes used for captioning.

 @return font attributes
 */
+ (NSDictionary *)fontAttributesDictionaryWithDefaultFontSize;

/**
 Font attributes used for captioning.

 @param imageSize size of GIF animation
 @param containerSize size of container (typically UIImageView) used for present GIF animation in
 @return font attributes
 */
+ (NSDictionary *)fontAttributesDictionaryBasedOnImageSize:(CGSize)imageSize containerSize:(CGSize)containerSize;

/**
 Font attributes used for captioning.

 @param fontSize needed font size to use
 @return font attributes
 */
+ (NSDictionary *)fontAttributesDictionaryWithSize:(NSInteger)fontSize;

@end
