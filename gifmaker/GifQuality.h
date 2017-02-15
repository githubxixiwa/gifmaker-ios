//
//  GifQuality.h
//  gifmaker
//
//  Created by Sergii Simakhin on 2/15/17.
//  Copyright © 2017 Cayugasoft. All rights reserved.
//

// Frameworks
#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

typedef NS_ENUM(NSInteger, GifQuality) {
    GifQualityLow = 0,
    GifQualityDefault = 1,
    GifQualityHigh = 2
};

CGFloat GifSideSizeFromQuality(GifQuality quality);
CGSize GifSizeFromQuality(GifQuality quality);
