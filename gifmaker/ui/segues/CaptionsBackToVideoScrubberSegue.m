//
//  CaptionsBackToVideoScrubberSegue.m
//  gifmaker
//
//  Created by Sergii Simakhin on 5/16/17.
//  Copyright © 2017 Cayugasoft. All rights reserved.
//

// Models
#import "CaptionsBackToVideoScrubberSegue.h"
#import "GifQuality.h"

// View Controllers
#import "VideoScrubberViewController.h"
#import "CaptionsViewController.h"

// Categories
#import "UIImageView+Extras.h"

// Helpers
#import "Macros.h"

@implementation CaptionsBackToVideoScrubberSegue

- (void)perform {
    CaptionsViewController *sourceVC = (CaptionsViewController *)self.sourceViewController;
    VideoScrubberViewController *destinationVC = (VideoScrubberViewController *)self.destinationViewController;
    
    destinationVC.previewEndImageView.alpha = 1;
    destinationVC.scrubberControlsUnderneathView.alpha = 1;
    destinationVC.startTitleLabel.alpha = 1;
    destinationVC.endTitleLabel.alpha = 1;
    
    // Set last video frame as 'preview end' image on captions VC
    sourceVC.previewEndImageView.image = [sourceVC.videoSource
                                          thumbnailAtFrame:sourceVC.videoSource.lastFrameNumber
                                          withSize:GifSizeFromQuality(GifQualityDefault)
                                          ];
    [sourceVC.previewEndImageView applyTriangleMask];
    
    // Animate settings view sliding back on video scrubber
    destinationVC.settingsViewBottomLayoutContraint.constant = 0;
    [destinationVC.view layoutIfNeeded];
    
    // Animate setting view sliding back on captions VC
    sourceVC.settingsViewBottomLayoutContraint.constant = 0;
    
    // Wrap saved video scrubber screenshot into UIImageView & add it above the filters view
    UIImageView *videoScrubberScreenshotView = [[UIImageView alloc] initWithImage:sourceVC.videoScrubberScreenshot];
    videoScrubberScreenshotView.alpha = 0;
    [sourceVC.filtersView addSubview:videoScrubberScreenshotView];
    
    // Hide filters
    [UIView animateWithDuration:CUSTOM_SEGUE_DURATION / 2 animations:^{
        sourceVC.filtersCollectionView.alpha = 0;
    }];
    
    // Run general animation
    [UIView animateWithDuration:CUSTOM_SEGUE_DURATION animations:^{
        [sourceVC.view layoutIfNeeded];
        
        sourceVC.headerCaptionTextField.alpha = 0;
        sourceVC.footerCaptionTextField.alpha = 0;
        
        sourceVC.startTitleLabel.alpha = 1;
        sourceVC.endTitleLabel.alpha = 1;
        sourceVC.previewEndImageView.alpha = 1;
        
        videoScrubberScreenshotView.alpha = 1;
    } completion:^(BOOL finished) {
        [sourceVC.navigationController popViewControllerAnimated:false];
    }];
}

@end
