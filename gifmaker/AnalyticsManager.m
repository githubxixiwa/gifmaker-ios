//
//  AnalyticsManager.m
//  gifmaker
//
//  Created by Sergio on 7/14/16.
//  Copyright © 2016 Cayugasoft. All rights reserved.
//

#import "AnalyticsManager.h"

@implementation AnalyticsManager

+ (instancetype)sharedAnalyticsManager
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once (&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

#pragma mark - Shared Analytics Methods

// Sharing methods

- (void)gifSharedViaIMessage {
    [self performAnalyticsActionWithTitle:@"gifSharedViaIMessage"];
}

- (void)gifSharedViaFacebookMessenger {
    [self performAnalyticsActionWithTitle:@"gifSharedViaFacebookMessenger"];
}

- (void)gifSharedViaFacebookWallpost {
    [self performAnalyticsActionWithTitle:@"gifSharedViaFacebookWallpost"];
}

- (void)gifSharedViaSavingLocallyAsVideo {
    [self performAnalyticsActionWithTitle:@"gifSharedViaSavingLocallyAsVideo"];
}

// App activities methods

- (void)gifCreatedFrom:(GifFrameSource)frameSource {
    switch (frameSource) {
        case GifFrameSourceCamera:
            [self gifCreatedFromCamera];
            break;
        case GifFrameSourceGalleryPhotos:
            [self gifCreatedFromGallery];
            break;
        case GifFrameSourceGalleryVideo:
            [self gifCreatedFromGallery];
            break;
        default:
            NSLog(@"Analytics:: can't report that gif was created due to gif frame source: %ld", (long)frameSource);
            break;
    }
}

- (void)gifCreatedFromGallery {
    [self performAnalyticsActionWithTitle:@"gifCreatedFromGallery"];
}

- (void)gifCreatedFromCamera {
    [self performAnalyticsActionWithTitle:@"gifCreatedFromCamera"];
}

- (void)gifEdited {
    [self performAnalyticsActionWithTitle:@"gifEdited"];
}

- (void)gifDeleted {
    [self performAnalyticsActionWithTitle:@"gifDeleted"];
}

// Error handlers
- (void)gifCreationError {
    [self performAnalyticsActionWithTitle:@"gifCreationError"];
}

@end
