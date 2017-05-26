//
//  VideoScrubberToCaptionsSegue.m
//  gifmaker
//
//  Created by Sergii Simakhin on 5/15/17.
//  Copyright © 2017 Cayugasoft. All rights reserved.
//

// Models
#import "VideoScrubberToCaptionsSegue.h"

// View Controllers
#import "VideoScrubberViewController.h"
#import "CaptionsViewController.h"

// Helpers
#import "Macros.h"

@implementation VideoScrubberToCaptionsSegue

- (void)perform {
    VideoScrubberViewController *sourceVC = (VideoScrubberViewController *)self.sourceViewController;
    CaptionsViewController *destinationVC = (CaptionsViewController *)self.destinationViewController;
    
    destinationVC.headerCaptionTextForced = @"";
    destinationVC.footerCaptionTextForced = @"";
    
    sourceVC.settingsViewBottomLayoutContraint.constant = -sourceVC.settingsView.frame.size.height;
    
    [UIView animateWithDuration:CUSTOM_SEGUE_DURATION animations:^{
        [sourceVC.view layoutIfNeeded];
        
        sourceVC.previewEndImageView.alpha = 0;
        sourceVC.scrubberControlsUnderneathView.alpha = 0;
        sourceVC.startTitleLabel.alpha = 0;
        sourceVC.endTitleLabel.alpha = 0;
    } completion:^(BOOL finished) {
        [sourceVC.navigationController pushViewController:destinationVC animated:false];
    }];
}

@end
