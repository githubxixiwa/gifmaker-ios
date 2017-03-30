//
//  GifManager.m
//  gifmaker
//
//  Created by Sergii Simakhin on 11/26/15.
//  Copyright © 2015 Cayugasoft. All rights reserved.
//

#define GIF_EXTENSION @"gif"
#define GIF_METADATA_EXTENSION @"metadata"

// Frameworks
#import <UIKit/UIKit.h>
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>

// Models
#import "GifManager.h"

@implementation GifManager

#pragma mark - Public Methods

+ (NSArray<NSURL *> *)localGIFSPaths {
    NSMutableArray<NSURL *> *localGIFSPathsArray = [NSMutableArray array];
    
    NSArray<NSString *> *filesInLocalStorageFolder = [self filesInLocalStorageFolder];
    for (NSString *file in filesInLocalStorageFolder) {
        if ([[file pathExtension] isEqualToString:GIF_EXTENSION]) {
            [localGIFSPathsArray addObject:[self gifURLWithFilename:file]];
        }
    }
    
    return localGIFSPathsArray;
}

+ (NSArray<NSURL *> *)localMetadataFilesPaths {
    NSMutableArray<NSURL *> *localMetadataFilesArray = [NSMutableArray array];
    
    NSArray<NSString *> *filesInLocalStorageFolder = [self filesInLocalStorageFolder];
    for (NSString *file in filesInLocalStorageFolder) {
        if ([[file pathExtension] isEqualToString:GIF_METADATA_EXTENSION]) {
            [localMetadataFilesArray addObject:[self metadataURLWithFilename:[file stringByDeletingPathExtension]]];
        }
    }
    
    return localMetadataFilesArray;
}

+ (NSURL *)gifRawFramesStorageFolderURL:(NSString *)filename {
    return [[self gifStorageFolderURL] URLByAppendingPathComponent:filename isDirectory:YES];
}

+ (NSURL *)gifURLWithFilename:(NSString *)filename {
    return [[self gifStorageFolderURL] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", filename, GIF_EXTENSION]];
}

+ (NSURL *)metadataURLWithFilename:(NSString *)filename {
    return [[self gifStorageFolderURL] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", filename, GIF_METADATA_EXTENSION]];
}

+ (BOOL)makeAnimatedGif:(NSArray<UIImage *> *)framesWithCaptions
              rawFrames:(NSArray<UIImage *> *)rawFrames
                    fps:(NSInteger)fps
          headerCaption:(NSString *)headerCaption
          footerCaption:(NSString *)footerCaption
            frameSource:(GifFrameSource)frameSource
         creationSource:(GifCreationSource)creationSource
                 filter:(Filter *)filter
               filename:(NSString *)filename {
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
    NSURL *fileURL = [self gifURLWithFilename:filename];
    
    // Init GIF-file
    CGImageDestinationRef destination = CGImageDestinationCreateWithURL((__bridge CFURLRef)fileURL, kUTTypeGIF, framesWithCaptions.count, NULL);
    CGImageDestinationSetProperties(destination, (__bridge CFDictionaryRef)fileProperties);
    
    // Fill GIF-file with frames
    for (UIImage *frame in framesWithCaptions) {
        CGImageDestinationAddImage(destination, frame.CGImage, (__bridge CFDictionaryRef)frameProperties);
    }
    
    // Finalize GIF-file
    if (!CGImageDestinationFinalize(destination)) {
        CFRelease(destination);
        NSLog(@"Failed to finalize image destination");
        return NO;
    }
    
    // Clean memory
    CFRelease(destination);
    
    // Save metadata on disk
    GifElement *element = [[GifElement alloc] initWithFilenameWithoutExtension:filename datePosted:[NSDate date]];
    [element setHeaderCaption:headerCaption];
    [element setFooterCaption:footerCaption];
    [element makeEditable:rawFrames];
    [element setFrameSource:frameSource];
    [element setCreationSource:creationSource];
    [element setFilter:filter];
    [element save];
    
    NSLog(@"Gif done");
    return YES;
}


#pragma mark - Private Methods

+ (NSArray<NSString *> *)filesInLocalStorageFolder {
    NSError *error;
    NSArray *filesInFolder = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[[self gifStorageFolderURL] relativePath] error:&error];
    if (error) {
        NSLog(@"Error getting local storage files: %@", [error localizedDescription]);
    }
    return filesInFolder;
}

+ (NSURL *)gifStorageFolderURL {
    return [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:nil];
}

@end
