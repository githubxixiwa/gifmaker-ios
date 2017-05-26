//
//  GifListToRecordSegue.m
//  gifmaker
//
//  Created by Sergii Simakhin on 5/18/17.
//  Copyright © 2017 Cayugasoft. All rights reserved.
//

// Models
#import "GifListToRecordSegue.h"

// View Controllers
#import "RecordViewController.h"
#import "GifListViewController.h"

// Helpers
#import "Macros.h"

@implementation GifListToRecordSegue

- (void)perform {
    GifListViewController *sourceVC = (GifListViewController *)self.sourceViewController;
    RecordViewController *destinationVC = (RecordViewController *)self.destinationViewController;
    
    sourceVC.recordingCardViewLeadingConstraint.constant = 4;
    sourceVC.recordingCardViewTrailingConstraint.constant = 4;
    sourceVC.tableViewTopConstraint.constant = [UIScreen mainScreen].bounds.size.height - HEADER_DEFAULT_HEIGHT;
    
    [UIView animateWithDuration:CUSTOM_SEGUE_DURATION animations:^{
        [sourceVC.view layoutIfNeeded];
        sourceVC.headerViewBottomLineView.alpha = 0;
    } completion:^(BOOL finished) {
        [sourceVC.navigationController pushViewController:destinationVC animated:false];
    }];
}

@end
