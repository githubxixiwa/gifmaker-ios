//
//  VideoScrubberToGifListSegue.m
//  gifmaker
//
//  Created by Sergii Simakhin on 5/17/17.
//  Copyright © 2017 Cayugasoft. All rights reserved.
//

// Models
#import "VideoScrubberToGifListSegue.h"

// View Controllers
#import "VideoScrubberViewController.h"
#import "GifListViewController.h"

// Helpers
#import "Macros.h"

@implementation VideoScrubberToGifListSegue

- (void)perform {
    VideoScrubberViewController *sourceVC = (VideoScrubberViewController *)self.sourceViewController;
    GifListViewController *destinationVC = (GifListViewController *)self.destinationViewController;
    
    // Add tableView screenshot to the offscreen bottom
    UIImage *tableViewScreenshot = destinationVC.tableViewScreenshot;
    UIImageView *tableViewScreenshotView = [[UIImageView alloc] initWithImage:tableViewScreenshot];
    tableViewScreenshotView.frame = CGRectMake([UIScreen mainScreen].bounds.origin.x, [UIScreen mainScreen].bounds.size.height, tableViewScreenshot.size.width, tableViewScreenshot.size.height);
    [sourceVC.view addSubview:tableViewScreenshotView];

    // Animate editing card movement to the right side
    [UIView animateWithDuration:CUSTOM_SEGUE_DURATION/2 animations:^{
        sourceVC.cardView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, [UIScreen mainScreen].bounds.size.width, 0);
    }];
    
    // Animate settings view sliding back on video scrubber
    sourceVC.settingsViewBottomLayoutContraint.constant = -sourceVC.settingsView.frame.size.height;
    
    // Animate tableView scroll up (technically it's just a screenshot)
    [UIView animateWithDuration:CUSTOM_SEGUE_DURATION animations:^{
        [sourceVC.view layoutIfNeeded];
        
        tableViewScreenshotView.frame = CGRectMake([UIScreen mainScreen].bounds.origin.x, HEADER_DEFAULT_HEIGHT, tableViewScreenshot.size.width, tableViewScreenshot.size.height);
        
        // Also fade in the header view bottom line
        sourceVC.headerViewBottomLine.alpha = 1;
    } completion:^(BOOL finished) {
        [sourceVC.navigationController popViewControllerAnimated:false];
    }];
}

@end
