//
//  CaptionsCancelsGifFromGalleryToGifList.m
//  gifmaker
//
//  Created by Sergii Simakhin on 5/17/17.
//  Copyright © 2017 Cayugasoft. All rights reserved.
//

// Models
#import "CaptionsCancelsGifFromGalleryToGifList.h"

// View Controllers
#import "CaptionsViewController.h"
#import "GifListViewController.h"

// Categories
#import "UIView+Extras.h"

// Helpers
#import "Macros.h"

@implementation CaptionsCancelsGifFromGalleryToGifList

- (void)perform {
    CaptionsViewController *sourceVC = (CaptionsViewController *)self.sourceViewController;
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
    
    // Animate tableView scroll up (technically it's just a screenshot)
    [UIView animateWithDuration:CUSTOM_SEGUE_DURATION animations:^{
        tableViewScreenshotView.frame = CGRectMake([UIScreen mainScreen].bounds.origin.x, HEADER_DEFAULT_HEIGHT, tableViewScreenshot.size.width, tableViewScreenshot.size.height);
        
        // Also fade in the header view bottom line
        sourceVC.headerViewBottomLineView.alpha = 1;
    } completion:^(BOOL finished) {
        [sourceVC.navigationController popViewControllerAnimated:false];
    }];
}

@end
