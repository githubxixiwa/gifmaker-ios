//
//  GifElement.h
//  gifmaker
//
//  Created by Sergio on 11/25/15.
//  Copyright © 2015 Cayugasoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// The way how gif was created.
typedef NS_ENUM(NSInteger, GifFrameSource) {
    GifFrameSourceUnknown,
    GifFrameSourceCamera,
    GifFrameSourceGallery
};

// GifCreationSourceBaked: means 'created' from Camera or else; GifCreationSourceEdited: means 'edited' using another gif as source.
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
