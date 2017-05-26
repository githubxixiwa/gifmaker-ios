//
//  RecordCancelsToGifListSegue.m
//  gifmaker
//
//  Created by Sergii Simakhin on 5/19/17.
//  Copyright © 2017 Cayugasoft. All rights reserved.
//

// Models
#import "RecordCancelsToGifListSegue.h"

// View Controllers
#import "RecordViewController.h"
#import "GifListViewController.h"

// Helpers
#import "Macros.h"

@implementation RecordCancelsToGifListSegue

- (void)perform {
    RecordViewController *sourceVC = (RecordViewController *)self.sourceViewController;
    GifListViewController *destinationVC = (GifListViewController *)self.destinationViewController;
    
    // Revert back header bottom line visibility
    destinationVC.headerViewBottomLineView.alpha = 1;
    
    // Set recording card to the offscreen position
    [destinationVC setRecordingCardToInitialPosition];
    
    // Animate table view scroll up from off-screen
    destinationVC.tableViewTopConstraint.constant = 0;
    
    // Add tableView screenshot to the offscreen bottom
    UIImageView *tableViewScreenshotView = [[UIImageView alloc] initWithImage:destinationVC.tableViewScreenshot];
    tableViewScreenshotView.frame = CGRectMake([UIScreen mainScreen].bounds.origin.x, [UIScreen mainScreen].bounds.size.height, destinationVC.tableViewScreenshot.size.width, destinationVC.tableViewScreenshot.size.height);
    [sourceVC.view addSubview:tableViewScreenshotView];
    
    // Animate editing card movement to the right side
    [UIView animateWithDuration:CUSTOM_SEGUE_DURATION/2 animations:^{
        sourceVC.cardView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, [UIScreen mainScreen].bounds.size.width, 0);
    }];
    
    // Animate tableView scroll up (technically it's just a screenshot)
    [UIView animateWithDuration:CUSTOM_SEGUE_DURATION animations:^{
        tableViewScreenshotView.frame = CGRectMake([UIScreen mainScreen].bounds.origin.x, HEADER_DEFAULT_HEIGHT, destinationVC.tableViewScreenshot.size.width, destinationVC.tableViewScreenshot.size.height);
        
        // Also fade in the header view bottom line
        sourceVC.headerViewBottomLineView.alpha = 1;
    } completion:^(BOOL finished) {
        [sourceVC.navigationController popViewControllerAnimated:false];
    }];
}

@end
