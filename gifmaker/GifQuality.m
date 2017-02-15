//
//  GifQuality.m
//  gifmaker
//
//  Created by Sergii Simakhin on 2/14/17.
//  Copyright © 2017 Cayugasoft. All rights reserved.
//

#import "GifQuality.h"

CGFloat GifSideSizeFromQuality(GifQuality quality) {
    switch (quality) {
        case GifQualityLow:
            return 240.0;
        case GifQualityDefault:
            return 480.0;
        case GifQualityHigh:
            return 960.0;
    }
}

CGSize GifSizeFromQuality(GifQuality quality) {
    CGFloat sideSize = GifSideSizeFromQuality(quality);
    return CGSizeMake(sideSize, sideSize);
}
