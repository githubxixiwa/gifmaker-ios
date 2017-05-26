//
//  RecordToCaptionsSegue.m
//  gifmaker
//
//  Created by Sergii Simakhin on 5/19/17.
//  Copyright © 2017 Cayugasoft. All rights reserved.
//

// Models
#import "RecordToCaptionsSegue.h"

// View Controllers
#import "RecordViewController.h"
#import "CaptionsViewController.h"

// Helpers
#import "Macros.h"

@implementation RecordToCaptionsSegue

- (void)perform {
    RecordViewController *sourceVC = (RecordViewController *)self.sourceViewController;
    CaptionsViewController *destinationVC = (CaptionsViewController *)self.destinationViewController;
    
    sourceVC.topCameraPreviewImageView.image = destinationVC.thumbnail;
    
    [UIView animateWithDuration:CUSTOM_SEGUE_DURATION animations:^{
        sourceVC.circularProgressView.alpha = 0;
        sourceVC.switchCameraButton.alpha = 0;
        sourceVC.topCameraPreviewImageView.alpha = 1;
    } completion:^(BOOL finished) {
        [sourceVC.navigationController pushViewController:destinationVC animated:false];
        sourceVC.circularProgressView.alpha = 1;
        sourceVC.switchCameraButton.alpha = 1;
    }];
}

@end
