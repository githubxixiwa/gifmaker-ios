//
//  CaptionsViewController.m
//  gifmaker
//
//  Created by Sergii Simakhin on 12/3/15.
//  Copyright © 2015 Cayugasoft. All rights reserved.
//

#define FILTER_TITLE_FONT_SIZE 12.0

// View Controllers
#import "CaptionsViewController.h"

// Models
#import "GifFilterCollectionViewCell.h"
#import "GifManager.h"
#import "AnalyticsManager.h"
#import "Filter.h"

// Categories
#import "NSString+Extras.h"
#import "UIImage+Extras.h"
#import "UIView+Extras.h"

// Helpers
#import "Macros.h"

@interface CaptionsViewController ()

/*! Center point of the current UIViewController's view. */
@property (nonatomic) CGPoint center;

@property (nonatomic) BOOL scrollViewOffsetDidSet;
@property (nonatomic) CGSize scrollViewDefaultSize;

@property (nonatomic, strong) NSArray<Filter *> *filters;
@property (nonatomic, strong) NSCache *cachedFilteredImages;

@end

@implementation CaptionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    [self.headerCaptionTextField setFont:[UIFont fontWithName:@"Impact" size:CAPTIONS_FONT_SIZE]];
    [self.footerCaptionTextField setFont:[UIFont fontWithName:@"Impact" size:CAPTIONS_FONT_SIZE]];
    
    // Set GIF preview image
    if (self.frameSource == GifFrameSourceGalleryPhotos || self.frameSource == GifFrameSourceCamera) {
        [self.GIFFirstFramePreviewImageView setImage:self.capturedImages.firstObject];
    } else if (self.frameSource == GifFrameSourceGalleryVideo) {
        if (self.creationSource == GifCreationSourceEdited) {
            [self.GIFFirstFramePreviewImageView setImage:self.capturedImages.firstObject];
        } else {
            [self.GIFFirstFramePreviewImageView setImage:self.videoSource.thumbnail];
        }
    }
    
    if (self.headerCaptionTextForced) {
        [self setAttributedTextAsCaptionToTextField:self.headerCaptionTextField text:self.headerCaptionTextForced];
    }
    if (self.footerCaptionTextForced) {
        [self setAttributedTextAsCaptionToTextField:self.footerCaptionTextField text:self.footerCaptionTextForced];
    }
    
    // Set up navigation bar buttons
    self.cancelButton.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(270));
    self.gifItButton.transform  = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(90));
    [self.cancelButton addTarget:self action:@selector(cancelButtonDidPress:)  forControlEvents:UIControlEventTouchUpInside];
    [self.gifItButton  addTarget:self action:@selector(makeGifButtonDidPress:) forControlEvents:UIControlEventTouchUpInside];
    
    // Hide keyboard (if it's open) on gif preview tap
    [self.GIFFirstFramePreviewImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gifPreviewImageDidTap:)]];
    
    // Set background image
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"backgroundWood1"]]];
    
    // Set shadow for the card
    [self.cardView applyShadow];
    
    // Init filters
    self.filters = @[
        [[Filter alloc] initWithTitle:@"Normal" ciFilterTitle:@""],
        [[Filter alloc] initWithTitle:@"Sepia" ciFilterTitle:@"CISepiaTone"],
        [[Filter alloc] initWithTitle:@"BW" ciFilterTitle:@"CIPhotoEffectMono"],
        [[Filter alloc] initWithTitle:@"Vintage" ciFilterTitle:@"CIPhotoEffectInstant"],
        [[Filter alloc] initWithTitle:@"Fade" ciFilterTitle:@"CIPhotoEffectFade"],
        [[Filter alloc] initWithTitle:@"Chrome" ciFilterTitle:@"CIPhotoEffectChrome"],
        [[Filter alloc] initWithTitle:@"Transfer" ciFilterTitle:@"CIPhotoEffectTransfer"]
    ];
    
    // Set active filter (not) if it's not set (first filter from filters list is always normal)
    if (self.activeFilter == nil) {
        self.activeFilter = self.filters.firstObject;
    } else {
        self.GIFFirstFramePreviewImageView.image = [self.GIFFirstFramePreviewImageView.image applyFilter:self.activeFilter];
    }
    
    // Init filtered images cache
    self.cachedFilteredImages = [[NSCache alloc] init];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.center = self.view.center;
    self.scrollViewDefaultSize = self.scrollView.frame.size;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.cachedFilteredImages removeAllObjects];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)gifPreviewImageDidTap:(id)sender {
    [self.view endEditing:YES];
    [self scrollViewDisableScrolling];
}


#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (!self.scrollViewOffsetDidSet) {
        [self scrollViewEnableScrolling];
    }
    
    if (textField == self.headerCaptionTextField) {
        [self animateAction:^{
            [self.scrollView setContentOffset:CGPointZero];
        }];
    } else {
        [self animateAction:^{
            [self.scrollView setContentOffset:CGPointMake(0, 0 + self.center.y / 2)];
        }];
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    if (textField == self.headerCaptionTextField) {
        [self.footerCaptionTextField becomeFirstResponder];
    } else {
        [self.headerCaptionTextField becomeFirstResponder];
    }
    
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    CGSize textSize = [[textField.text stringByAppendingString:[string uppercaseString]] sizeWithAttributes:@{NSFontAttributeName:textField.font}];
    
    if (textSize.width > textField.bounds.size.width) {
        return NO;
    } else {
        [self setAttributedTextAsCaptionToTextField:textField text:string];
        return [string isEqualToString:@""];
    }
}

- (void)setTextToHeaderCaption:(NSString*)text {
    [self setAttributedTextAsCaptionToTextField:self.headerCaptionTextField text:text];
}

- (void)setTextToFooterCaption:(NSString*)text {
    [self setAttributedTextAsCaptionToTextField:self.footerCaptionTextField text:text];
}

- (void)setAttributedTextAsCaptionToTextField:(UITextField *)textField text:(NSString *)text {
    NSString *capitalizedString = [textField.text stringByAppendingString:[text uppercaseString]];
    [textField setAttributedText:[self attributedStringWithText:capitalizedString]];
}


#pragma mark - UICollectionView Delegate Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.filters.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return [collectionView dequeueReusableCellWithReuseIdentifier:@"filterCell" forIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(nonnull UICollectionViewCell *)cell forItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    GifFilterCollectionViewCell *displayCell = (GifFilterCollectionViewCell *)cell;
    Filter *displayFilter = self.filters[indexPath.row];
    
    // Check if we have filtered image in cache
    if ([self.cachedFilteredImages objectForKey:displayFilter.title] == nil) {
        // If not, make it & cache
        
        [displayCell setAlpha:0.0];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *thumbnail = (self.frameSource == GifFrameSourceGalleryVideo && self.creationSource != GifCreationSourceEdited) ? self.videoSource.thumbnail : self.capturedImages.firstObject;
            UIImage *filteredImage = [thumbnail applyFilter:displayFilter];
            [self.cachedFilteredImages setObject:filteredImage forKey:displayFilter.title];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                displayCell.previewImage.image = filteredImage;
                [UIView animateWithDuration:0.3 animations:^{
                    [displayCell setAlpha:1.0];
                }];
            });
        });
    } else {
        [displayCell setAlpha:1.0];
        displayCell.previewImage.image = [self.cachedFilteredImages objectForKey:displayFilter.title];
    }
    
    displayCell.title.text = displayFilter.title;
    
    // Make bold font for title if current filter is an active filter
    if ([displayFilter.title isEqualToString:self.activeFilter.title]) {
        displayCell.title.font = [UIFont boldSystemFontOfSize:FILTER_TITLE_FONT_SIZE];
    } else {
        displayCell.title.font = [UIFont systemFontOfSize:FILTER_TITLE_FONT_SIZE];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    GifFilterCollectionViewCell *selectedCell = (GifFilterCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    self.activeFilter = self.filters[indexPath.row];
    
    // Set all filter titles to regular font
    for (GifFilterCollectionViewCell *visibleCell in [collectionView visibleCells]) {
        visibleCell.title.font = [UIFont systemFontOfSize:FILTER_TITLE_FONT_SIZE];
    }
    
    // Make selected filter title bold
    selectedCell.title.font = [UIFont boldSystemFontOfSize:FILTER_TITLE_FONT_SIZE];
    
    // Set filtered image as a GIF's preview image
    self.GIFFirstFramePreviewImageView.image = selectedCell.previewImage.image;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(CGRectGetHeight(collectionView.frame) * 0.75, CGRectGetHeight(collectionView.frame));
}


#pragma mark - Navigation Buttons Methods

- (void)cancelButtonDidPress:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
}

- (void)makeGifButtonDidPress:(id)sender {
    // Get GIF size (based on settings)
    CGSize gifSize = GifSizeFromQuality(self.videoSource.outputGifQuality);
    
    // Disable 'GIF IT!' button
    [self.gifItButton setEnabled:NO];
    
    // Disable 'Cancel' button
    [self.cancelButton setEnabled:NO];
    
    // Disable ability to change filter by tapping on it
    [self.filtersCollectionView setUserInteractionEnabled:NO];
    
    // Disable scrolling
    [self.scrollView setScrollEnabled:false];
    
    // Dismiss keyboard (if open)
    [self.view endEditing:YES];
    
    // Animate card: flip it and animate the app logo
    dispatch_async(dispatch_get_main_queue(), ^{
        // Hide captions with animation
        [UIView animateWithDuration:0.2 animations:^{
            [self.headerCaptionTextField setHidden:YES];
            [self.footerCaptionTextField setHidden:YES];
        }];
        
        // Flip card view an app logo
        [UIView transitionWithView:self.cardView
                          duration:0.64
                           options:UIViewAnimationOptionTransitionFlipFromRight
                        animations:^{
                            // Set the app logo image on flip
                            self.GIFFirstFramePreviewImageView.image = [UIImage imageNamed:@"weareallmakers"];
                            [self.filtersCollectionView setHidden:YES];
                        } completion:^(BOOL finished) {
                            // Rotate app logo
                            CABasicAnimation* rotationAnimation;
                            rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
                            rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0];
                            rotationAnimation.duration = 4.0;
                            rotationAnimation.cumulative = YES;
                            rotationAnimation.repeatCount = INT_MAX;
                            
                            [self.GIFFirstFramePreviewImageView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
                        }];
    });
    
    // Do in backgroud: extract frames, save them, convert to GIF animation
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray<UIImage *> *gifReadyImagesWithCaptions = [NSMutableArray array];
        NSMutableArray<UIImage *> *gifReadyImagesWithoutCaptions = [NSMutableArray array];
        
        // If frameSource is a video (to make a GIF from), take all needed frames(images) first
        if (self.frameSource == GifFrameSourceGalleryVideo && self.creationSource != GifCreationSourceEdited) {
            self.capturedImages = [NSMutableArray array];
            
            //Step through the frames (the counter must rely on fps: for 25fps video it will take every second frame, because typical gif fps number is 16)
            for (NSInteger counter = self.videoSource.firstFrameNumber; counter <= self.videoSource.lastFrameNumber; counter += round(self.videoSource.fps / GIF_FPS)) {
                @autoreleasepool {
                    NSLog(@"%@", [NSString stringWithFormat:@"Will handle %lu frame", (unsigned long)self.capturedImages.count]);
                    if (self.capturedImages.count >= ANIMATION_MAX_DURATION * GIF_FPS) {
                        break;
                    }

                    [self.capturedImages addObject:[self.videoSource thumbnailAtFrame:counter withSize:gifSize]];
                }
            }
        }
        
        // Get real font size, because font size on screen is mostly smaller than original default gif size (480)
        CGFloat sideSize = self.videoSource ? GifSideSizeFromQuality(self.videoSource.outputGifQuality) : ((UIImage *)self.capturedImages.firstObject).size.width;
        NSInteger realFontSize = (CAPTIONS_FONT_SIZE * (sideSize / self.GIFFirstFramePreviewImageView.frame.size.width)) + 1;
        
        // Add captions to the images
        for (UIImage *capturedImage in self.capturedImages) {
            @autoreleasepool {
                UIImage *capturedImageFiltered = [capturedImage applyFilter:self.activeFilter];
                UIImage *imageWithTextOnIt = [capturedImageFiltered drawHeaderText:self.headerCaptionTextField.attributedText.string
                                                                footerText:self.footerCaptionTextField.attributedText.string
                                                  withAttributesDictionary:[self attributesDictionaryWithFontSize:realFontSize]
                                                                forQuality:self.videoSource == nil ? GifQualityDefault : self.videoSource.outputGifQuality
                                              ];
                UIImage *imageWithTextOnItCompressed = [UIImage imageWithData:UIImageJPEGRepresentation(imageWithTextOnIt, 0.2)];
                UIImage *imageWithoutTextCompressed = [UIImage imageWithData:UIImageJPEGRepresentation(capturedImage, 0.2)];
                [gifReadyImagesWithCaptions addObject:imageWithTextOnItCompressed];
                [gifReadyImagesWithoutCaptions addObject:imageWithoutTextCompressed];
            }
        }
        
        // Inform analytics that GIF was baked with filter (title is included)
        if (![self.activeFilter isNormal]) {
            [[AnalyticsManager sharedAnalyticsManager] gifAppliedFilter:self.activeFilter.title];
        }
    
        // Make GIF
        if ([GifManager makeAnimatedGif:gifReadyImagesWithCaptions
                              rawFrames:gifReadyImagesWithoutCaptions
                                    fps:GIF_FPS
                          headerCaption:self.headerCaptionTextField.attributedText.string
                          footerCaption:self.footerCaptionTextField.attributedText.string
                            frameSource:self.frameSource
                         creationSource:self.creationSource
                                 filter:self.activeFilter
                               filename:[NSString generateRandomString]]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                // Gif done
                
                // Perform analytics network calls
                if (self.creationSource == GifCreationSourceEdited) {
                    [[AnalyticsManager sharedAnalyticsManager] gifEdited];
                } else if (self.creationSource == GifCreationSourceBaked) {
                    [[AnalyticsManager sharedAnalyticsManager] gifCreatedFrom:self.frameSource];
                }
                
                // Perform 'done'-stage actions
                [[self delegate] refresh];
                [self.navigationController popToRootViewControllerAnimated:YES];
            });
        } else {
            NSLog(@"Gif creation error");
            [[AnalyticsManager sharedAnalyticsManager] gifCreationError];
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Oops!" message:@"Error occured!" preferredStyle:UIAlertControllerStyleAlert];
                [alertController addAction:[UIAlertAction actionWithTitle:@"Go back" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }]];
                [self presentViewController:alertController animated:YES completion:nil];
            });
        }
    });
}


#pragma mark - Helpers

- (NSAttributedString *)attributedStringWithText:(NSString *)text {
    return [[NSAttributedString alloc] initWithString:text attributes:[self attributesDictionaryWithFontSize:CAPTIONS_FONT_SIZE]];
}

- (NSDictionary *)attributesDictionaryWithFontSize:(NSInteger)fontSize {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributesDictionary = @{
                                           NSStrokeColorAttributeName: [UIColor blackColor],
                                           NSForegroundColorAttributeName: [UIColor whiteColor],
                                           NSParagraphStyleAttributeName: paragraphStyle,
                                           NSStrokeWidthAttributeName: @(-4.0),
                                           NSFontAttributeName: [UIFont fontWithName:@"Impact" size:fontSize]
                                           };
    return attributesDictionary;
}

- (void)scrollViewEnableScrolling {
    self.scrollViewOffsetDidSet = YES;
    [self animateAction:^{
        [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, self.scrollView.frame.size.height + self.center.y / 2)];
    }];
}

- (void)scrollViewDisableScrolling {
    self.scrollViewOffsetDidSet = NO;
    [self animateAction:^{
        [self.scrollView setContentSize:self.scrollViewDefaultSize];
    }];
}

- (void)animateAction:(void (^)())action {
    [UIView animateWithDuration:0.24 animations:^{
        action(self);
    }];
}

@end
