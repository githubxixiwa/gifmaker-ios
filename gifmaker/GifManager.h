//
//  GifManager.h
//  gifmaker
//
//  Created by Sergio on 11/26/15.
//  Copyright © 2015 Cayugasoft. All rights reserved.
//

// Frameworks
#import <Foundation/Foundation.h>

// Models
#import "GifElement.h"

@interface GifManager : NSObject

/*! Array of paths to the all gifs in the app's documents folder. */
+ (NSArray<NSURL *> *)localGIFSPaths;

/*! Array of paths to the all metadata files. */
+ (NSArray<NSURL *> *)localMetadataFilesPaths;

/*! Return NSURL for the new GIF. You should pass 'filename' argument without extension. */
+ (NSURL *)gifURLWithFilename:(NSString *)filename;

+ (NSURL *)metadataURLWithFilename:(NSString *)filename;

/*! Load all local GIFS from storage with it's metadata */
//+ (void)loadStorage;

@end
