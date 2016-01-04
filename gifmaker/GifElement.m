//
//  GifElement.m
//  gifmaker
//
//  Created by Sergio on 11/25/15.
//  Copyright © 2015 Cayugasoft. All rights reserved.
//

#define kFilename @"filename"
#define kDatePosted @"datePosted"
#define kEditable @"editable"
#define kHeaderCaption @"headerCaption"
#define kFooterCaption @"footerCaption"

// Models
#import "GifElement.h"
#import "GifManager.h"
#import "Exporter.h"

// Categories
#import "UIImage+animatedGIF.h"

@implementation GifElement

- (instancetype)initWithFilenameWithoutExtension:(NSString *)filename datePosted:(NSDate *)datePosted {
    self = [super init];
    if (self) {
        self.filename   = filename;
        self.datePosted = datePosted;
        self.editable   = NO;
        self.headerCaption = @"";
        self.footerCaption = @"";
    }
    
    return self;
}

- (instancetype)initWithMetadataFile:(NSURL *)metadataFileURL {
    self = [NSKeyedUnarchiver unarchiveObjectWithFile:[metadataFileURL relativePath]];
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.filename      = [decoder decodeObjectForKey:kFilename];
    self.datePosted    = [decoder decodeObjectForKey:kDatePosted];
    self.editable      = [decoder decodeObjectForKey:kEditable];
    self.headerCaption = [decoder decodeObjectForKey:kHeaderCaption];
    self.footerCaption = [decoder decodeObjectForKey:kFooterCaption];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.filename forKey:kFilename];
    [encoder encodeObject:self.datePosted forKey:kDatePosted];
    [encoder encodeObject:@(self.editable) forKey:kEditable];
    [encoder encodeObject:self.headerCaption forKey:kHeaderCaption];
    [encoder encodeObject:self.footerCaption forKey:kFooterCaption];
}

- (void)makeEditable:(NSArray<UIImage *> *)images {
    self.editable = YES;
    
    [[NSFileManager defaultManager] createDirectoryAtURL:[self savedFramesStorageFolderURL]
                             withIntermediateDirectories:YES
                                              attributes:nil
                                                   error:nil];
    
    for (int i = 0; i < images.count; i++) {
        NSURL *imageURL = [[self savedFramesStorageFolderURL] URLByAppendingPathComponent:[NSString stringWithFormat:@"%d.png", i]];
        [UIImagePNGRepresentation(images[i]) writeToFile:[imageURL path] atomically:YES];
    }
}

- (NSArray<UIImage *> *)getEditableFrames {
    BOOL isDirectory = YES;
    if ([[NSFileManager defaultManager] fileExistsAtPath:[[self savedFramesStorageFolderURL] path] isDirectory:&isDirectory]) {
        NSError *contentsOfDirectoryError;
        NSMutableArray *imagesPathArray = [NSMutableArray arrayWithArray:[[NSFileManager defaultManager] contentsOfDirectoryAtPath:[[self savedFramesStorageFolderURL] path]
                                                                                       error:&contentsOfDirectoryError]];
        // Numeric sort, just to ensure that images are in proper order
        [imagesPathArray sortUsingComparator:^NSComparisonResult(NSString *str1, NSString *str2) {
            return [str1 compare:str2 options:(NSNumericSearch)];
        }];
        
        if (contentsOfDirectoryError) {
            NSLog(@"Error during scanning folder for stored frames: %@", [contentsOfDirectoryError localizedDescription]);
            return nil;
        } else {
            NSMutableArray<UIImage *> *images = [NSMutableArray array];
            for (NSString *pathToImage in imagesPathArray) {
                UIImage *image = [UIImage imageWithContentsOfFile:[[[self savedFramesStorageFolderURL] URLByAppendingPathComponent:pathToImage] path]];
                [images addObject:image];
            }
            return images;
        }
    } else {
        return nil;
    }
}

- (NSURL *)gifURL {
    return [GifManager gifURLWithFilename:self.filename];
}

- (NSURL *)savedFramesStorageFolderURL {
    return [GifManager gifRawFramesStorageFolderURL:self.filename];
}

- (void)save {
    [NSKeyedArchiver archiveRootObject:self toFile:[[GifManager metadataURLWithFilename:self.filename] relativePath]];
}

- (void)removeFromDisk {
    NSError *gifFileRemoveError;
    if (![[NSFileManager defaultManager] removeItemAtURL:[self gifURL] error:&gifFileRemoveError]) {
        NSLog(@"Can't delege GIFfile, error: %@", [gifFileRemoveError localizedDescription]);
    }
    
    NSError *metadataFileRemoveError;
    if (![[NSFileManager defaultManager] removeItemAtURL:[GifManager metadataURLWithFilename:self.filename] error:&metadataFileRemoveError]) {
        NSLog(@"Can't delede metadata file, error: %@", [metadataFileRemoveError localizedDescription]);
    }
    
    NSError *storageFolderRemoveError;
    if (![[NSFileManager defaultManager] removeItemAtURL:[GifManager gifRawFramesStorageFolderURL:self.filename] error:&storageFolderRemoveError]) {
        NSLog(@"Can't delede raw storage folder, error: %@", [storageFolderRemoveError localizedDescription]);
    }
}

- (void)saveToGalleryAsVideo {
    [Exporter exportImageArrayAsVideo:[UIImage animatedImageWithAnimatedGIFURL:[self gifURL]].images
                             filename:@"temp.mov"
                          repeatCount:5
                        saveToGallery:YES];
}

@end
