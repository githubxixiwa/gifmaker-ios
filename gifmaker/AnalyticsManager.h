//
//  AnalyticsManager.h
//  gifmaker
//
//  Created by Sergio on 7/14/16.
//  Copyright © 2016 Cayugasoft. All rights reserved.
//

// Models
#import "NetworkManager.h"
#import "GifElement.h"

@interface AnalyticsManager : NetworkManager

+ (instancetype)sharedAnalyticsManager;

// Sharing methods
- (void)gifSharedViaIMessage;
- (void)gifSharedViaFacebookMessenger;
- (void)gifSharedViaFacebookWallpost;
- (void)gifSharedViaSavingLocallyAsVideo;

// App activities methods
- (void)gifCreatedFrom:(GifFrameSource)frameSource;
- (void)gifCreatedFromGallery;
- (void)gifCreatedFromCamera;
- (void)gifEdited;
- (void)gifDeleted;

// Error handlers
- (void)gifCreationError;

@end
