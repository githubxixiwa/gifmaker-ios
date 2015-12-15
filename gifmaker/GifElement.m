//
//  GifElement.m
//  gifmaker
//
//  Created by Sergio on 11/25/15.
//  Copyright © 2015 Cayugasoft. All rights reserved.
//

#define kFilename @"filename"
#define kDatePosted @"datePosted"

#import "GifElement.h"
#import "GifManager.h"
#import "Exporter.h"
#import "UIImage+animatedGIF.h"

@implementation GifElement

- (instancetype)initWithFilenameWithoutExtension:(NSString *)filename datePosted:(NSDate *)datePosted {
    self = [super init];
    if (self) {
        self.filename   = filename;
        self.datePosted = datePosted;
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
    
    self.filename = [decoder decodeObjectForKey:kFilename];
    self.datePosted = [decoder decodeObjectForKey:kDatePosted];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.filename forKey:kFilename];
    [encoder encodeObject:self.datePosted forKey:kDatePosted];
}

- (NSURL *)gifURL {
    return [GifManager gifURLWithFilename:self.filename];
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
        NSLog(@"Can't delede metadata file, error: %@", [gifFileRemoveError localizedDescription]);
    }
}

- (void)saveToGalleryAsVideo {
    [Exporter exportImageArrayAsVideo:[UIImage animatedImageWithAnimatedGIFURL:[self gifURL]].images
                             filename:@"temp.mov"
                          repeatCount:5
                        saveToGallery:YES];
}

@end
