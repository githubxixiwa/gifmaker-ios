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

@implementation GifElement

- (instancetype) initWithFilenameWithoutExtension:(NSString*)filename datePosted:(NSDate*)datePosted {
    self = [super init];
    if (self) {
        self.filename   = filename;
        self.datePosted = datePosted;
    }
    
    return self;
}

- (instancetype) initWithMetadataFile:(NSURL*)metadataFileURL {
    self = [NSKeyedUnarchiver unarchiveObjectWithFile:[metadataFileURL relativePath]];
    return self;
}

- (id) initWithCoder:(NSCoder*)decoder {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.filename = [decoder decodeObjectForKey:kFilename];
    self.datePosted = [decoder decodeObjectForKey:kDatePosted];
    
    return self;
}

- (void) encodeWithCoder:(NSCoder*)encoder {
    [encoder encodeObject:self.filename forKey:kFilename];
    [encoder encodeObject:self.datePosted forKey:kDatePosted];
}

- (NSURL *)gifURL {
    return [GifManager gifURLWithFilename:self.filename];
}

- (void) save {
    [NSKeyedArchiver archiveRootObject:self toFile:[[GifManager metadataURLWithFilename:self.filename] relativePath]];
}

@end
