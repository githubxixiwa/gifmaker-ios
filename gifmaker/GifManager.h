//
//  GifManager.h
//  gifmaker
//
//  Created by Sergio on 11/26/15.
//  Copyright © 2015 Cayugasoft. All rights reserved.
//

// Frameworks
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

// Models
#import "GifElement.h"

@interface GifManager : NSObject

/*! Array of paths to the all gifs in the app's documents folder. */
+ (NSArray<NSURL *> *)localGIFSPaths;

/*! Array of paths to the all metadata files. */
+ (NSArray<NSURL *> *)localMetadataFilesPaths;

/*! Return NSURL for the GIF's raw frames storage. Mostly used for changing captions later by user. */
+ (NSURL *)gifRawFramesStorageFolderURL:(NSString *)filename;

/*! Return NSURL for the new GIF. You should pass 'filename' argument without extension. */
+ (NSURL *)gifURLWithFilename:(NSString *)filename;

/*! Return NSURL of metadata file for passed 'filename'. You should pass 'filename' argument without extension. */
+ (NSURL *)metadataURLWithFilename:(NSString *)filename;

/*! Make GIF from 'framesWithCaptions' array. Keeping 'rawFrames' for editing feature.
    Returns 'YES' if GIF done successfully, returns 'NO' on error.
    Filename should be without extension. */
+ (BOOL)makeAnimatedGif:(NSArray<UIImage *> *)framesWithCaptions
              rawFrames:(NSArray<UIImage *> *)rawFrames
                    fps:(NSInteger)fps
          headerCaption:(NSString *)headerCaption
          footerCaption:(NSString *)footerCaption
               filename:(NSString *)filename;

@end
