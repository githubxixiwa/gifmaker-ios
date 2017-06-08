//
//  EndEditingSegue.m
//  gifmaker
//
//  Created by Sergii Simakhin on 4/10/17.
//  Copyright © 2017 Cayugasoft. All rights reserved.
//

// Segues
#import "EditGifSegue.h"
#import "EndEditingSegue.h"

// View Controllers
#import "GifListViewController.h"
#import "CaptionsViewController.h"
#import "VideoScrubberViewController.h"

// Helpers
#import "Macros.h"

@implementation EndEditingSegue

- (void)perform {
    CaptionsViewController *sourceVC = (CaptionsViewController *)self.sourceViewController;
    GifListViewController *destinationVC = (GifListViewController *)self.destinationViewController;
    
    // Get previously edited cell (it was edited by tapping on related icon in gif list so we need it to reset all transforms back)
    GifTableViewCell *editingGifCell = [destinationVC.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:sourceVC.editingGifIndex inSection:0]];
    
    // The size of card at the destination view controller
    CGSize cardSize = sourceVC.cardView.frame.size;
    
    // Calculate params for the transformation: degree for the card rotation, xTransform & yTransform for scaling
    double rads = DEGREES_TO_RADIANS(editingGifCell.inclineDegree);
    double xTransform = editingGifCell.cardView.bounds.size.width / cardSize.width;
    double yTransform = editingGifCell.cardView.bounds.size.height / cardSize.height;

    // Wrap 'rotate' and 'scale' action into one transform
    CGAffineTransform rotateScale = CGAffineTransformConcat(
        CGAffineTransformRotate(CGAffineTransformIdentity, rads),
        CGAffineTransformScale(CGAffineTransformIdentity, xTransform, yTransform)
    );
    
    CGRect rectInTableView = [destinationVC.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:sourceVC.editingGifIndex inSection:0]];
    CGRect cardRectInVisiblePartOfWindow = [destinationVC.tableView convertRect:rectInTableView toView:[destinationVC.tableView superview]];
    
    CGFloat yOffset = 0;
    NSInteger magicNumber = 10;
    
    if (sourceVC.editingGifIndex == 0) {
        if (self.animationType == EndEditingGifAnimationTypeBakedGIF) {
            // Reset card origin Y point (reason: fully visible header must present on a gif list [when the new GIF will appear on top]). By setting HEADER_DEFAULT_HEIGHT it will remove any offsets caused by user before gif editing process.
            cardRectInVisiblePartOfWindow.origin.y = HEADER_DEFAULT_HEIGHT;
        }
        
        yOffset = magicNumber - destinationVC.headerViewBottomLineView.frame.size.height - (HEADER_DEFAULT_HEIGHT - cardRectInVisiblePartOfWindow.origin.y);
    } else {
        yOffset = -(HEADER_DEFAULT_HEIGHT - cardRectInVisiblePartOfWindow.origin.y) + magicNumber - destinationVC.headerViewBottomLineView.frame.size.height;
    }
    
    // Wrap 'rotate', 'scale' and 'move' into one transform
    CGAffineTransform rotateScaleTranslate = CGAffineTransformConcat(
        rotateScale,
        CGAffineTransformTranslate(CGAffineTransformIdentity, 0, yOffset)
    );
    
    /* Prepare transformation constants */
    CGFloat gifCardXTransform = 1 - GifCardXTransformConstant;
    CGFloat gifCardYTransform = 1 - GifCardYTransformConstant;
    
    // Reset all transformations on a cell at destination view controller
    [editingGifCell resetTransform];
    [editingGifCell makeSubviewsVisible];
    
    // Set header bottom line visible
    destinationVC.headerViewBottomLineView.alpha = 1.0;
    
    if (self.animationType == EndEditingGifAnimationTypeCancel) {
        /* Hides captions because user canceling his changes. So ignore user's caption changes. */
        
        // Check if captions have any text. If so, hide them.
        if (![sourceVC.headerCaptionTextField.text isEqualToString:@""]) {
            sourceVC.headerCaptionTextField.alpha = 0;
        }
        if (![sourceVC.footerCaptionTextField.text isEqualToString:@""]) {
            sourceVC.footerCaptionTextField.alpha = 0;
        }
        
        // Revert header contraint value to old one on 'Cancel' animation
        destinationVC.headerViewTopConstraint.constant = destinationVC.headerViewTopConstraintOldValue;
        sourceVC.headerViewTopConstraint.constant = destinationVC.headerViewTopConstraintOldValue;
    } else {
        // Scroll table view to top on 'Baked GIF' animation (because new animations are always on top in the list of gifs)
        [destinationVC.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:false];
    }
    
    // Begin animation
    [UIView animateWithDuration:CUSTOM_SEGUE_DURATION animations:^{
        // Apply transformation for the whole card view
        sourceVC.cardView.transform = rotateScaleTranslate;
        
        // Apply transformation for the gifView (where animation's first frame was sot)
        sourceVC.GIFFirstFramePreviewImageView.transform = CGAffineTransformConcat(
            CGAffineTransformScale(CGAffineTransformIdentity, gifCardXTransform, gifCardYTransform),
            CGAffineTransformTranslate(CGAffineTransformIdentity, 0, 0)
        );
        
        // Set border for the gif preview (as on destination view controller)
        sourceVC.GIFFirstFramePreviewImageView.layer.borderWidth = 1;
        sourceVC.GIFFirstFramePreviewImageView.layer.borderColor = [UIColor blackColor].CGColor;
        
        // Run this block only on 'Cancel' animation type
        if (self.animationType == EndEditingGifAnimationTypeCancel) {
            // Hide captions
            sourceVC.headerCaptionTextField.alpha = 0;
            sourceVC.footerCaptionTextField.alpha = 0;
        }
        
        // Hide filters
        sourceVC.filtersCollectionView.alpha = 0;
        
        // Show header bottom line as at destination view controller
        sourceVC.headerViewBottomLineView.alpha = 1;
        
        // Set thumbnail image as preview image
        sourceVC.GIFFirstFramePreviewImageView.image = sourceVC.thumbnail;
        
        [sourceVC.view endEditing:YES];
        [sourceVC.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        if ([sourceVC.parentViewController isKindOfClass:[UINavigationController class]]) {
            // Check if user have 'Record VC' in navigation tree, if so - bring back the table view and remove the 'record' UIView card from the screen
            if (sourceVC.navigationController.viewControllers.count >= 1) {
                if ([sourceVC.navigationController.viewControllers[1] isKindOfClass:[RecordViewController class]]) {
                    // Set recording card to the offscreen position
                    [destinationVC setRecordingCardToInitialPosition];
                    
                    // Animate table view scroll up from off-screen
                    destinationVC.tableViewTopConstraint.constant = 0;
                }
            }
            
            [sourceVC.navigationController popToRootViewControllerAnimated:false];
        } else {
            [sourceVC dismissViewControllerAnimated:false completion:nil];
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [destinationVC.tableView reloadData];
        });
    }];
}

@end
