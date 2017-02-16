//
//  VideoSource.h
//  gifmaker
//
//  Created by Sergii Simakhin on 1/13/17.
//  Copyright © 2017 Cayugasoft. All rights reserved.
//

// Frameworks
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

// Models
#import "GifQuality.h"

@interface VideoSource : NSObject

@property (nonatomic, strong) UIImage *thumbnail;
@property (nonatomic) NSInteger fps;
@property (nonatomic) Float64 duration;
@property (nonatomic) NSInteger framesCount;
@property (nonatomic) UIInterfaceOrientation orientation;
@property (nonatomic, strong) AVAsset *asset;
@property (nonatomic) GifQuality outputGifQuality;

@property (nonatomic) NSInteger firstFrameNumber;
@property (nonatomic) NSInteger lastFrameNumber;

- (instancetype)initWithAsset:(AVAsset *)asset;

/**
 Extract frame (image) from video (it will be cropped to rectangle)

 @param frameNumber number of frame
 @param size specified size (rectangle preferred) of extracted frame
 @return image of specified frame number (can be nil if frame doesn't exist)
 */
- (UIImage *)thumbnailAtFrame:(NSUInteger)frameNumber withSize:(CGSize)size;

@end
