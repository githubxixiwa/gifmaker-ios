//
//  VideoSource.m
//  gifmaker
//
//  Created by Sergii Simakhin on 1/13/17.
//  Copyright © 2017 Cayugasoft. All rights reserved.
//

// Models
#import "VideoSource.h"

// Categories
#import "UIImage+Extras.h"

// Helpers
#import "Macros.h"

@interface VideoSource ()

@property (nonatomic, strong) AVAssetImageGenerator *imageGenerator;

@end

@implementation VideoSource

- (instancetype)initWithAsset:(AVAsset *)asset {
    self = [super init];
    if (self) {
        self.asset = asset;
        
        // Extract video track from asset
        NSArray *movieTracks = [asset tracksWithMediaType:AVMediaTypeVideo];
        AVAssetTrack *movieTrack = [movieTracks firstObject];
        
        // Set video source properties using asset & movie track 
        self.fps = movieTrack.nominalFrameRate + 1;
        self.duration = CMTimeGetSeconds(asset.duration);
        self.framesCount = self.duration * movieTrack.nominalFrameRate;
        self.orientation = [self extractOrientationFromVideoTrack:movieTrack];
        self.outputGifQuality = GifQualityDefault;
        
        self.firstFrameNumber = 0;
        self.lastFrameNumber = VIDEO_DURATION * self.fps;
        self.thumbnail = [self thumbnailAtFrame:self.firstFrameNumber withSize:GifSizeFromQuality(self.outputGifQuality)];
        
        // Set up image generator
        self.imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        self.imageGenerator.requestedTimeToleranceAfter = kCMTimeZero;
        self.imageGenerator.requestedTimeToleranceBefore = kCMTimeZero;
        self.imageGenerator.appliesPreferredTrackTransform = YES;
    }
    
    return self;
}

- (UIInterfaceOrientation)extractOrientationFromVideoTrack:(AVAssetTrack *)videoTrack {
    CGSize size = [videoTrack naturalSize];
    CGAffineTransform transform = [videoTrack preferredTransform];
    
    if (size.width == transform.tx && size.height == transform.ty)
        return UIInterfaceOrientationLandscapeRight;
    else if (transform.tx == 0 && transform.ty == 0)
        return UIInterfaceOrientationLandscapeLeft;
    else if (transform.tx == 0 && transform.ty == size.width)
        return UIInterfaceOrientationPortraitUpsideDown;
    else
        return UIInterfaceOrientationPortrait;
}

- (UIImage *)thumbnailAtFrame:(NSUInteger)frameNumber withSize:(CGSize)size {
    NSError *error;
    CGImageRef frameCGImage = [self.imageGenerator copyCGImageAtTime:CMTimeMake(frameNumber, (CGFloat)self.fps) actualTime:nil error:&error];
    
    if (error != nil) {
        NSLog(@"App encountered an error during getting a frame number %lu: %@", (unsigned long)frameNumber, [error localizedDescription]);
        return nil;
    }
    
    UIImage *frameImage = [UIImage imageByCroppingVideoFrameCGImage:frameCGImage toSize:size];
    CGImageRelease(frameCGImage);
    
    return frameImage;
}

@end
