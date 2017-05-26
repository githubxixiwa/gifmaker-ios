//
//  CaptionsBackToRecordSegue.m
//  gifmaker
//
//  Created by Sergii Simakhin on 5/22/17.
//  Copyright © 2017 Cayugasoft. All rights reserved.
//

// Models
#import "CaptionsBackToRecordSegue.h"

// View Controllers
#import "RecordViewController.h"
#import "CaptionsViewController.h"

// Helpers
#import "Macros.h"

@implementation CaptionsBackToRecordSegue

- (void)perform {
    CaptionsViewController *sourceVC = (CaptionsViewController *)self.sourceViewController;
    RecordViewController *destinationVC = (RecordViewController *)self.destinationViewController;
    
    sourceVC.blackGifPreviewSublayer.alpha = 1;
    destinationVC.topCameraPreviewImageView.alpha = 0;
    
    [UIView animateWithDuration:CUSTOM_SEGUE_DURATION animations:^{
        sourceVC.headerCaptionTextField.alpha = 0;
        sourceVC.footerCaptionTextField.alpha = 0;
        sourceVC.filtersView.alpha = 0;
        sourceVC.GIFFirstFramePreviewImageView.alpha = 0;
    } completion:^(BOOL finished) {
        [sourceVC.navigationController popViewControllerAnimated:false];
    }];
}

@end
