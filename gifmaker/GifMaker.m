//
//  GifMaker.m
//  gifmaker
//
//  Created by Sergio on 11/24/15.
//  Copyright © 2015 Cayugasoft. All rights reserved.
//

// Frameworks
#import <UIKit/UIKit.h>
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>

// Models
#import "GifMaker.h"
#import "GifManager.h"

@implementation GifMaker

+ (BOOL)makeAnimatedGif:(NSArray*)frames fps:(NSInteger)fps filename:(NSString*)filename {
    // Set up GIF-file properties
    NSDictionary *fileProperties = @{
                                     (__bridge id)kCGImagePropertyGIFDictionary: @{
                                             (__bridge id)kCGImagePropertyGIFLoopCount: @0, // 0 means loop forever
                                             }
                                     };
    
    NSDictionary *frameProperties = @{
                                      (__bridge id)kCGImagePropertyGIFDictionary: @{
                                              (__bridge id)kCGImagePropertyGIFDelayTime: @(1.0 / fps), // a float (not double!) in seconds, rounded to centiseconds in the GIF data
                                              }
                                      };
    
    // Save file in documents folder with filename as method argument
    NSURL *fileURL = [GifManager gifURLWithFilename:filename];
    
    // Init GIF-file
    CGImageDestinationRef destination = CGImageDestinationCreateWithURL((__bridge CFURLRef)fileURL, kUTTypeGIF, frames.count, NULL);
    CGImageDestinationSetProperties(destination, (__bridge CFDictionaryRef)fileProperties);
    
    // Fill GIF-file with frames
    for (UIImage *frame in frames) {
        CGImageDestinationAddImage(destination, frame.CGImage, (__bridge CFDictionaryRef)frameProperties);
    }
    
    // Finalize GIF-file
    if (!CGImageDestinationFinalize(destination)) {
        NSLog(@"failed to finalize image destination");
        return false;
    }
    
    // Clean memory
    CFRelease(destination);
    
    // Save metadata on disk
    GifElement *element = [[GifElement alloc] initWithFilenameWithoutExtension:filename datePosted:[NSDate date]];
    [element save];
    
    NSLog(@"Gif done");
    return true;
}

@end
