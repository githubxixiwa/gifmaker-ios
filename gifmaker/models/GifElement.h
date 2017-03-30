//
//  GifElement.h
//  gifmaker
//
//  Created by Sergii Simakhin on 11/25/15.
//  Copyright © 2015 Cayugasoft. All rights reserved.
//

// Frameworks
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// Models
#import "Filter.h"

// The way how gif was created
typedef NS_ENUM(NSInteger, GifFrameSource) {
    GifFrameSourceUnknown,
    GifFrameSourceCamera,
    GifFrameSourceGalleryPhotos,
    GifFrameSourceGalleryVideo
};

// GifCreationSourceBaked: means 'created' from Camera or else; GifCreationSourceEdited: means 'edited' using another gif as a source
typedef NS_ENUM(NSInteger, GifCreationSource) {
    GifCreationSourceUnknown,
    GifCreationSourceBaked,
    GifCreationSourceEdited
};

@interface GifElement : NSObject <NSCoding>

/*! Filename without extension */
@property (nonatomic, strong) NSString *filename;

@property (nonatomic, strong) NSDate *datePosted;
@property (nonatomic) GifFrameSource frameSource;
@property (nonatomic) GifCreationSource creationSource;
@property (nonatomic, strong) NSString *headerCaption;
@property (nonatomic, strong) NSString *footerCaption;
@property (nonatomic, strong) Filter *filter;
@property (nonatomic) BOOL editable;

/**
 Create an instance of GifElement using filename (can be any) and date (usually current)

 @param filename name of file for the new GifElement (can be any)
 @param datePosted date when GifElement was created (usually current)
 @return instance of new GifElement
 */
- (instancetype)initWithFilenameWithoutExtension:(NSString *)filename datePosted:(NSDate *)datePosted;

/**
 Load GifElement from disk using specified NSURL

 @param metadataFileURL NSURL of metadata file
 @return instance of GifElement (which is stored on disk)
 */
- (instancetype)initWithMetadataFile:(NSURL *)metadataFileURL;

/*! GIF file path on disk */
- (NSURL *)gifURL;

/*! Save (metadata file) on disk */
- (void)save;

/*! Permanently remove gif file and metadata file */
- (void)removeFromDisk;

/*! Export current GIF animation as a video (looped a couple of times) to the iOS Photos.app gallery */
- (void)saveToGalleryAsVideo;

/* Save gif's raw frames to make possibility to change a captions in the future */
- (void)makeEditable:(NSArray<UIImage *> *)images;

/* Get gif's raw frames (typically used to change a captions) */
- (NSArray<UIImage *> *)getEditableFrames;

@end
