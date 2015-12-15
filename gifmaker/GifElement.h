//
//  GifElement.h
//  gifmaker
//
//  Created by Sergio on 11/25/15.
//  Copyright © 2015 Cayugasoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GifElement : NSObject <NSCoding>

/*! Filename without extension */
@property (nonatomic, strong) NSString *filename;
@property (nonatomic, strong) NSDate *datePosted;

- (instancetype)initWithFilenameWithoutExtension:(NSString *)filename datePosted:(NSDate *)datePosted;
- (instancetype)initWithMetadataFile:(NSURL *)metadataFileURL;
- (NSURL *)gifURL;

/*! Save on disk */
- (void)save;

/*! Permanently remove gif file and metadata file */
- (void)removeFromDisk;

- (void)saveToGalleryAsVideo;

@end
