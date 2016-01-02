//
//  GifElement.h
//  gifmaker
//
//  Created by Sergio on 11/25/15.
//  Copyright © 2015 Cayugasoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface GifElement : NSObject <NSCoding>

/*! Filename without extension */
@property (nonatomic, strong) NSString *filename;
@property (nonatomic, strong) NSDate *datePosted;
@property (nonatomic, strong) NSString *headerCaption;
@property (nonatomic, strong) NSString *footerCaption;
@property (nonatomic) BOOL editable;

- (instancetype)initWithFilenameWithoutExtension:(NSString *)filename datePosted:(NSDate *)datePosted;
- (instancetype)initWithMetadataFile:(NSURL *)metadataFileURL;
- (NSURL *)gifURL;

/*! Save on disk */
- (void)save;

/*! Permanently remove gif file and metadata file */
- (void)removeFromDisk;

- (void)saveToGalleryAsVideo;

/* Save gif's raw frames to make possibility to change a captions in the future. */
- (void)makeEditable:(NSArray<UIImage *> *)images;

/* Get gif's raw frames (to get ability to change a captions). */
- (NSArray<UIImage *> *)getEditableFrames;

@end
