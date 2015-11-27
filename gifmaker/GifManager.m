//
//  GifManager.m
//  gifmaker
//
//  Created by Sergio on 11/26/15.
//  Copyright © 2015 Cayugasoft. All rights reserved.
//

#define GIF_EXTENSION @"gif"
#define GIF_METADATA_EXTENSION @"metadata"

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

+ (NSURL *)gifURLWithFilename:(NSString *)filename {
    return [[self gifStorageFolderURL] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", filename, GIF_EXTENSION]];
}

+ (NSURL *)metadataURLWithFilename:(NSString *)filename {
    return [[self gifStorageFolderURL] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", filename, GIF_METADATA_EXTENSION]];
}

+ (void)addNewGifToStorageIndex:(GifElement *)gifElement {
    
    [self saveStorage];
}


#pragma mark - Private Methods

+ (void)saveStorage {
    
}

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
