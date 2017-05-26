//
//  EditGifSegue.m
//  gifmaker
//
//  Created by Sergii Simakhin on 4/4/17.
//  Copyright © 2017 Cayugasoft. All rights reserved.
//

#import "EditGifSegue.h"

// View Controllers
#import "GifListViewController.h"
#import "CaptionsViewController.h"

// Helpers
#import "UIImage+Extras.h"
#import "Macros.h"

@implementation EditGifSegue

- (void)perform {
    GifListViewController *sourceVC = (GifListViewController *)self.sourceViewController;
    CaptionsViewController *destinationVC = (CaptionsViewController *)self.destinationViewController;

    // The size of card at the destination view controller
    CGSize cardSize = destinationVC.cardSize;
    
    // Calculate params for the transformation: degree for the card rotation, xTransform & yTransform for scaling
    double rads = DEGREES_TO_RADIANS(360 - self.editingGifCell.inclineDegree);
    double xTransform = cardSize.width / self.editingGifCell.cardView.bounds.size.width;
    double yTransform = cardSize.height / self.editingGifCell.cardView.bounds.size.height;

    // Wrap 'rotate' and 'scale' action into one transform
    CGAffineTransform rotateScale = CGAffineTransformConcat(
        CGAffineTransformRotate(CGAffineTransformIdentity, rads),
        CGAffineTransformScale(CGAffineTransformIdentity, xTransform, yTransform)
    );
    
    // Get cell absolute coordinates in tableView
    CGRect rectInTableView = [sourceVC.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:destinationVC.editingGifIndex inSection:0]];
    CGRect cardRectInVisiblePartOfWindow = [sourceVC.tableView convertRect:rectInTableView toView:[sourceVC.tableView superview]];
    
    CGFloat yOffset = 0;
    NSInteger magicNumber = 10;
    
    // Calculate yOffset for the cell (will be used for Y affine transformation, means moving by Y)
    if (self.editingGifCell.frame.origin.y == 0) {
        // First cell detected
        if (cardRectInVisiblePartOfWindow.origin.y >= HEADER_DEFAULT_HEIGHT) {
            yOffset = -magicNumber;
        } else {
            yOffset = HEADER_DEFAULT_HEIGHT - cardRectInVisiblePartOfWindow.origin.y - magicNumber + sourceVC.headerViewTopConstraint.constant;
        }
    } else {
        // Not first cell (2nd, 3rd, any other else except of 1st)
        yOffset = HEADER_DEFAULT_HEIGHT - cardRectInVisiblePartOfWindow.origin.y - magicNumber + sourceVC.headerViewTopConstraint.constant;
    }
    
    // Wrap 'rotate', 'scale' and 'move' into one transform
    CGAffineTransform rotateScaleTranslate = CGAffineTransformConcat(
        rotateScale,
        CGAffineTransformTranslate(CGAffineTransformIdentity, 0, yOffset)
    );
    
    /* Prepare transformation constants */
    CGFloat gifViewYTransform = 4;
    
    CGFloat gifCardXTransform = 1 + GifCardXTransformConstant;
    CGFloat gifCardYTransform = 1 + GifCardYTransformConstant;
    
    CGFloat gifCardXTransformAdditionalConstant = 0.006;
    CGFloat gifCardYTransformAdditionalConstant = 0.014;
    
    // Determine iPhone family by screen height
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    
    // iPhone 5/5S/SE family
    if (screenHeight == 568) {
        gifCardXTransform += gifCardXTransformAdditionalConstant;
        gifCardYTransform += gifCardYTransformAdditionalConstant * 2;
    }
    
    // iPhone 6/7 family
    if (screenHeight == 667) {
        // Do nothing
    }
    
    // iPhone Plus family
    if (screenHeight == 736) {
        gifViewYTransform += 1;
        gifCardXTransform += gifCardXTransformAdditionalConstant;
        gifCardYTransform += gifCardYTransformAdditionalConstant;
    }

    // Stop animation and set first frame as shown
    [self.editingGifCell.gifView stopAnimating];
    [self.editingGifCell.gifView setImage:destinationVC.thumbnail];
    
    // Begin animation
    sourceVC.headerViewTopConstraint.constant = 0;
    [UIView animateWithDuration:CUSTOM_SEGUE_DURATION animations:^{
        [sourceVC.view layoutIfNeeded];
    }];
    
    [UIView animateWithDuration:CUSTOM_SEGUE_DURATION/2 animations:^{
        if (self.previousGifCell != nil) {
            self.previousGifCell.alpha = 0;
        }
        
        if (self.nextGifCell != nil) {
            self.nextGifCell.alpha = 0;
        }
    }];
    
    [UIView animateWithDuration:CUSTOM_SEGUE_DURATION animations:^{
        // Apply transformation for the whole card view
        self.editingGifCell.transform = rotateScaleTranslate;

        // Apply transformation for the gifView (where animation's first frame was sot)
        self.editingGifCell.gifView.transform = CGAffineTransformConcat(
            CGAffineTransformScale(CGAffineTransformIdentity, gifCardXTransform, gifCardYTransform),
            CGAffineTransformTranslate(CGAffineTransformIdentity, 0, gifViewYTransform)
        );
        
        // Make gifView border invisible
        self.editingGifCell.gifView.layer.borderWidth = 0;
        
        // Hide 'posted with love' label
        self.editingGifCell.postedDateLabel.alpha = 0;
        
        // Move share/edit/remove buttons a bit down and make them invisible
        self.editingGifCell.underneathButtonsStackView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, 20);
        self.editingGifCell.underneathButtonsStackView.alpha = 0;
        
        // Make view controller's header bottom line invisible
        sourceVC.headerViewBottomLineView.alpha = 0;
    } completion:^(BOOL finished) {
        [sourceVC presentViewController:destinationVC animated:NO completion:nil];
    }];
}

@end
