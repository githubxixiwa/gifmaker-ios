//
//  CaptionsViewController.m
//  gifmaker
//
//  Created by Sergio on 12/3/15.
//  Copyright © 2015 Cayugasoft. All rights reserved.
//

#define FONT_SIZE 40
#define SMALL_SCREEN ([UIScreen mainScreen].bounds.size.height < 667)

#import "Macros.h"

// View Controllers
#import "CaptionsViewController.h"

// Models
#import "GifManager.h"
#import "AnalyticsManager.h"

// Categories
#import "NSString+Extras.h"
#import "UIImage+Extras.h"

@interface CaptionsViewController ()

/*! Center point of the current UIViewController's view. */
@property (nonatomic) CGPoint center;
@property (nonatomic) BOOL scrollViewOffsetDidSet;
@property (nonatomic) CGSize scrollViewDefaultSize;

@end

@implementation CaptionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    [self.headerCaptionTextField setFont:[UIFont fontWithName:@"Impact" size:FONT_SIZE]];
    [self.footerCaptionTextField setFont:[UIFont fontWithName:@"Impact" size:FONT_SIZE]];
    
    if (self.frameSource == GifFrameSourceGalleryPhotos) {
        [self.GIFFirstFramePreviewImageView setImage:self.capturedImages.lastObject];
    } else if (self.frameSource == GifFrameSourceGalleryVideo) {
        [self.GIFFirstFramePreviewImageView setImage:self.videoSource.thumbnail];
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
    [self.cardView.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [self.cardView.layer setShadowOffset:CGSizeMake(6, 6)];
    [self.cardView.layer setShadowRadius:3.0];
    [self.cardView.layer setShadowOpacity:0.3];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.center = self.view.center;
    self.scrollViewDefaultSize = self.scrollView.frame.size;
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


#pragma mark - Navigation Buttons Methods

- (void)cancelButtonDidPress:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
}

- (void)makeGifButtonDidPress:(id)sender {
    // Disable 'GIF IT!' button
    [self.gifItButton setEnabled:NO];
    
    // Disable 'Cancel' button
    [self.cancelButton setEnabled:NO];
    
    // Dismiss keyboard (if open)
    [self.view endEditing:YES];
    
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
                        } completion:^(BOOL finished) {
                            // Animate app logo rotation if we are making GIF from video (usually it takes longer time)
                            if (self.frameSource == GifFrameSourceGalleryVideo) {
                                CABasicAnimation* rotationAnimation;
                                rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
                                rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0];
                                rotationAnimation.duration = 4.0;
                                rotationAnimation.cumulative = YES;
                                rotationAnimation.repeatCount = INT_MAX;
                                
                                [self.GIFFirstFramePreviewImageView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
                            }
                        }];
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray<UIImage *> *gifReadyImagesWithCaptions = [NSMutableArray array];
        NSMutableArray<UIImage *> *gifReadyImagesWithoutCaptions = [NSMutableArray array];
        
        // If frameSource is a video (to make a GIF from), take all needed frames(images) first
        if (self.frameSource == GifFrameSourceGalleryVideo) {
            self.capturedImages = [[NSMutableArray alloc] init];
            
            AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:self.videoSource.asset];
            imageGenerator.requestedTimeToleranceAfter = kCMTimeZero;
            imageGenerator.requestedTimeToleranceBefore = kCMTimeZero;
            imageGenerator.appliesPreferredTrackTransform = YES;

            Float64 videoDuration = CMTimeGetSeconds(self.videoSource.asset.duration);
            Float64 totalFrames = videoDuration * self.videoSource.fps;
            
            //Step through the frames (the counter must rely on fps: for 25fps video it will take every second frame, because typical gif fps number is 16)
            for (int counter = 0; counter <= totalFrames; counter += round(self.videoSource.fps / GIF_FPS)) {
                @autoreleasepool {
                    NSLog(@"%@", [NSString stringWithFormat:@"Will handle %lu frame", (unsigned long)self.capturedImages.count]);
                    if (self.capturedImages.count >= VIDEO_DURATION * GIF_FPS) {
                        break;
                    }
                    
                    NSError *error;
                    CGImageRef cgImage = [imageGenerator copyCGImageAtTime:CMTimeMake(counter, (int32_t)self.videoSource.fps) actualTime:nil error:&error];
                    UIImage *croppedImage = [UIImage imageByCroppingVideoFrameCGImage:cgImage toSize:CGSizeMake(GIF_SIDE_SIZE, GIF_SIDE_SIZE)];
                    CGImageRelease(cgImage);
                    
                    [self.capturedImages addObject:croppedImage];
                }
            }
        }
        
        // Add captions to the images
        for (UIImage *capturedImage in self.capturedImages) {
            @autoreleasepool {
                UIImage *imageWithTextOnIt = [self drawTextOnImage:capturedImage
                                              headerText:self.headerCaptionTextField.attributedText.string
                                              footerText:self.footerCaptionTextField.attributedText.string];
                UIImage *imageWithTextOnItCompressed = [UIImage imageWithData:UIImageJPEGRepresentation(imageWithTextOnIt, 0.2)];
                UIImage *imageWithoutTextCompressed = [UIImage imageWithData:UIImageJPEGRepresentation(capturedImage, 0.2)];
                [gifReadyImagesWithCaptions addObject:imageWithTextOnItCompressed];
                [gifReadyImagesWithoutCaptions addObject:imageWithoutTextCompressed];
            }
        }
    
        // Make GIF
        if ([GifManager makeAnimatedGif:gifReadyImagesWithCaptions
                              rawFrames:gifReadyImagesWithoutCaptions
                                    fps:GIF_FPS
                          headerCaption:self.headerCaptionTextField.attributedText.string
                          footerCaption:self.footerCaptionTextField.attributedText.string
                            frameSource:self.frameSource
                         creationSource:self.creationSource
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

/*! Used for captions text style */
- (NSAttributedString *)attributedStringWithText:(NSString *)text {
    return [[NSAttributedString alloc] initWithString:text attributes:[self attributesDictionaryWithFontSize:FONT_SIZE]];
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

- (UIImage *)drawTextOnImage:(UIImage *)image headerText:(NSString *)headerText footerText:(NSString *)footerText {
    UIGraphicsBeginImageContext(CGSizeMake(GIF_SIDE_SIZE, GIF_SIDE_SIZE));
    
    // Draw image on context
    [image drawAtPoint:CGPointMake(0, 0)];
    
    // Get real font size, because font size on screen is mostly smaller than original GIF_SIZE_SIZE (480)
    NSInteger realFontSize = (FONT_SIZE * (GIF_SIDE_SIZE / self.GIFFirstFramePreviewImageView.frame.size.width)) + 1;
    
    // Get attributed text size
    NSDictionary *attributesDictionary = [self attributesDictionaryWithFontSize:realFontSize];
    CGSize headerTextSize = [headerText sizeWithAttributes:attributesDictionary];
    CGSize footerTextSize = [footerText sizeWithAttributes:attributesDictionary];
    
    NSInteger offset = 2;
    
    CGRect headerCaptionRect = CGRectMake(offset,
                                          offset * 2,
                                          GIF_SIDE_SIZE - (offset * 2),
                                          headerTextSize.height);
    
    CGRect footerCaptionRect = CGRectMake(offset,
                                          GIF_SIDE_SIZE - (offset * 2) - footerTextSize.height,
                                          GIF_SIDE_SIZE - (offset * 2),
                                          footerTextSize.height);
    
    // Draw header and footer
    [headerText drawInRect:headerCaptionRect withAttributes:attributesDictionary];
    [footerText drawInRect:footerCaptionRect withAttributes:attributesDictionary];
    
    // Make image out of bitmap context
    UIImage *imageWithHeaderAndFooterText = UIGraphicsGetImageFromCurrentImageContext();
    
    // Free the context
    UIGraphicsEndImageContext();
    
    return imageWithHeaderAndFooterText;
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
