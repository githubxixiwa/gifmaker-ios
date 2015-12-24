//
//  CaptionsViewController.m
//  gifmaker
//
//  Created by Sergio on 12/3/15.
//  Copyright © 2015 Cayugasoft. All rights reserved.
//

#define FONT_SIZE 40
#define SMALL_SCREEN ([UIScreen mainScreen].bounds.size.height < 667)

// View Controllers
#import "CaptionsViewController.h"

// Models
#import "GifManager.h"

// Categories
#import "NSString+Extras.h"

@interface CaptionsViewController ()

/*! Center point of the current UIViewController's view. */
@property (nonatomic) CGPoint center;

@end

@implementation CaptionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Add captions";
    
    [self.headerCaptionTextField setFont:[UIFont fontWithName:@"Impact" size:FONT_SIZE]];
    [self.footerCaptionTextField setFont:[UIFont fontWithName:@"Impact" size:FONT_SIZE]];
    [self.GIFFirstFramePreviewImageView setImage:self.capturedImages.lastObject];
    
    // Set up navigation bar buttons
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonDidPress:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"GIF IT!" style:UIBarButtonItemStyleDone target:self action:@selector(makeGifButtonDidPress:)];
    
    // Hide keyboard (if it's open) on gif preview tap
    [self.GIFFirstFramePreviewImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gifPreviewImageDidTap:)]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.center = self.view.center;
}

- (void)gifPreviewImageDidTap:(id)sender {
    [self.view endEditing:YES];
}

- (void)errorOccured:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}


#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (SMALL_SCREEN) {
        if (textField == self.headerCaptionTextField) {
            self.view.center = self.center;
        } else {
            self.view.center = CGPointMake(self.center.x, self.center.y / 2);
        }
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    if (textField == self.headerCaptionTextField) {
        [self.footerCaptionTextField becomeFirstResponder];
        if (SMALL_SCREEN) {
            self.view.center = CGPointMake(self.center.x, self.center.y / 2);
        }
    } else {
        [self.headerCaptionTextField becomeFirstResponder];
        if (SMALL_SCREEN) {
            self.view.center = self.center;
        }
    }
    
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    CGSize textSize = [[textField.text stringByAppendingString:[string uppercaseString]] sizeWithAttributes:@{NSFontAttributeName:textField.font}];
    
    if (textSize.width > textField.bounds.size.width) {
        return NO;
    } else {
        NSString *capitalizedString = [textField.text stringByAppendingString:[string uppercaseString]];
        [textField setAttributedText:[self attributedStringWithText:capitalizedString]];
        return [string isEqualToString:@""];
    }
}


#pragma mark - Navigation Buttons Methods

- (void)cancelButtonDidPress:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)makeGifButtonDidPress:(id)sender {
    // Disable 'GIT IT!' button
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    
    // Hide navigation bar and dismiss keyboard (if open)
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.view endEditing:YES];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // Hide instructions and captions with animation
        [UIView animateWithDuration:0.2 animations:^{
            [self.instructionsLabel setHidden:YES];
            [self.headerCaptionTextField setHidden:YES];
            [self.footerCaptionTextField setHidden:YES];
        }];
        
        // Flip GIF preview view a app logo
        [UIView transitionWithView:self.GIFFirstFramePreviewImageView
                          duration:0.64
                           options:UIViewAnimationOptionTransitionFlipFromRight
                        animations:^{
                            // Set the app logo image on flip
                            self.GIFFirstFramePreviewImageView.image = [UIImage imageNamed:@"weareallmakers"];
                        } completion:^(BOOL finished) {
                            // Do something when animation is finished
                        }];
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray<UIImage *> *gifReadyImagesWithCaptions = [NSMutableArray array];
        NSMutableArray<UIImage *> *gifReadyImagesWithoutCaptions = [NSMutableArray array];
        
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
                               filename:[NSString generateRandomString]]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                // Gif done
                [[self delegate] refresh];
                [self.navigationController popToRootViewControllerAnimated:YES];
            });
        } else {
            NSLog(@"Gif creating error");
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.instructionsLabel setHidden:NO];
                [self.instructionsLabel setText:@"Oops! Gif creating error.\nTap app logo to return."];
                [self.GIFFirstFramePreviewImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(errorOccured:)]];
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

@end
