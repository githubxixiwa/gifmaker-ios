//
//  VideoScrubberViewController.m
//  gifmaker
//
//  Created by Sergii Simakhin on 1/17/17.
//  Copyright © 2017 Cayugasoft. All rights reserved.
//

#define PREVIEW_FRAMES_COUNT 6
#define STEPPER_IN_SECONDS 1 // STEP OF SCROLLING A TIMELINE IN SECONDS

// Frameworks
#import <QuartzCore/QuartzCore.h>

// View Controllers
#import "VideoScrubberViewController.h"
#import "CaptionsViewController.h"

// Models
#import "GifElement.h"

// Categories
#import "UIImage+Extras.h"
#import "UIView+Extras.h"
#import "UIImageView+Extras.h"

// Helpers
#import "Macros.h"

@interface VideoScrubberViewController ()

@property (nonatomic, strong) AVAssetImageGenerator *imageGenerator;
@property (nonatomic) NSInteger prevOffsetPointX;
@property (nonatomic, strong) NSCache *frameCache;
@property (nonatomic) NSInteger stepperInPix;

@end

@implementation VideoScrubberViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.frameCache = [[NSCache alloc] init];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"backgroundWood1"]]];
    
    self.cancelButton.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(270));
    self.nextButton.transform   = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(90));
    
    self.imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:self.videoSource.asset];
    self.imageGenerator.requestedTimeToleranceAfter = kCMTimeZero;
    self.imageGenerator.requestedTimeToleranceBefore = kCMTimeZero;
    
    [self.scrubberDragger addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(scrubberDidPan:)]];
    
    self.prevOffsetPointX = 0;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.videoSource.firstFrameNumber = 0;
    self.videoSource.lastFrameNumber = VIDEO_DURATION * self.videoSource.fps;

    [self.previewStartImageView setImageWithCheckingOrientation:[self thumbnailAtFrame:self.videoSource.firstFrameNumber]
                                                    orientation:self.videoSource.orientation];
    [self.previewEndImageView setImageWithCheckingOrientation:[self thumbnailAtFrame:self.videoSource.lastFrameNumber]
                                                  orientation:self.videoSource.orientation];
    
    /* Set 5 frames for the seeker frame previews */
    
    // Calculate frame step (divide by 5 because it's number of preview frames in scrubber)
    NSInteger frameStep = self.videoSource.framesCount / PREVIEW_FRAMES_COUNT;
    NSMutableArray *previewFrames = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < self.videoSource.framesCount; i += frameStep) {
        UIImage *thumbnail = [self thumbnailAtFrame:i];
        if (thumbnail != nil) {
            [previewFrames addObject:[self thumbnailAtFrame:i]];
        } else {
            NSLog(@"Error:: can't get thumbnail at frame %d for the preview", i);
            break;
        }
        
        if (previewFrames.count == PREVIEW_FRAMES_COUNT) {
            break;
        }
    }
    
    // Prepare scrubber preview frames
    NSArray<UIImageView *> *scrubberPreviewFrames = @[
        self.scrubberFrame1,
        self.scrubberFrame2,
        self.scrubberFrame3,
        self.scrubberFrame4,
        self.scrubberFrame5,
        self.scrubberFrame6,
    ];
    
    // Set preview images for the scrubber frames
    for (int i = 0; i < PREVIEW_FRAMES_COUNT; i++) {
        [scrubberPreviewFrames[i] setImageWithCheckingOrientation:previewFrames[i] orientation:self.videoSource.orientation];
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];

    /* Add mask to the END image */
    CGRect frame = self.previewEndImageView.frame;
    
    UIBezierPath *trianglePath = [UIBezierPath bezierPath];
    [trianglePath moveToPoint:CGPointMake(0, frame.size.height)];
    [trianglePath addLineToPoint:CGPointMake(frame.size.width, 0)];
    [trianglePath addLineToPoint:CGPointMake(frame.size.width, frame.size.height)];
    [trianglePath closePath];
    
    CAShapeLayer *previewEndImageViewTriangleMask = [CAShapeLayer layer];
    [previewEndImageViewTriangleMask setPath:trianglePath.CGPath];
    
    self.previewEndImageView.layer.mask = previewEndImageViewTriangleMask;
    
    /* Make scrubber view the underneath frames by adding a mask */
    UIBezierPath *frameLookerMaskPath = [UIBezierPath bezierPathWithRect:self.scrubberDraggerBackgroundView.frame];
    [frameLookerMaskPath appendPath:[UIBezierPath bezierPathWithRect:self.scrubberDraggerContentView.frame]];
    
    CAShapeLayer *scrubberClearMask = [CAShapeLayer layer];
    scrubberClearMask.fillRule  = kCAFillRuleEvenOdd;
    scrubberClearMask.fillColor = [UIColor blackColor].CGColor;
    scrubberClearMask.path      = frameLookerMaskPath.CGPath;
    
    self.scrubberDraggerBackgroundView.layer.mask = scrubberClearMask;
    
    /* Set scrubber cinema tape border */
    self.scrubberCinemaTapeView.layer.borderWidth = 2.0;
    self.scrubberCinemaTapeView.layer.borderColor = [UIColor blackColor].CGColor;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Update scrubber frame size related to max gif time (5 seconds) according to video lenght
    self.scrubberWidthLayoutConstraint.constant = (self.scrubberFramesStackView.frame.size.width / self.videoSource.framesCount) * (self.videoSource.fps * VIDEO_DURATION);
    [UIView animateWithDuration:0.1 animations:^{
        [self.scrubberDragger setNeedsUpdateConstraints];
        [self.scrubberDragger setAlpha:1.0];
    }];
    
    self.stepperInPix = self.scrubberFramesStackView.frame.size.width / self.videoSource.duration / STEPPER_IN_SECONDS;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.frameCache removeAllObjects];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)scrubberDidPan:(UIPanGestureRecognizer *)panGesture {
    CGPoint offsetPoint = [panGesture translationInView:panGesture.view];
    offsetPoint.x = offsetPoint.x + (self.stepperInPix - ((NSInteger)offsetPoint.x % self.stepperInPix));
    
    NSInteger newConstant = self.scrubberLeadingLayoutConstraint.constant;
    
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan: {
            newConstant = self.scrubberLeadingLayoutConstraint.constant + offsetPoint.x;
            break;
        }
        case UIGestureRecognizerStateEnded:
            break;
        case UIGestureRecognizerStateFailed:
            break;
        case UIGestureRecognizerStateChanged: {
            newConstant = self.scrubberLeadingLayoutConstraint.constant + (offsetPoint.x - self.prevOffsetPointX);
            break;
        }
        case UIGestureRecognizerStateCancelled:
            break;
        default:
            break;
    }
    
    // Check if new constant exceed the start and end limits (and set it after)
    if (newConstant <= 0) {
        self.scrubberLeadingLayoutConstraint.constant = 0;
    } else if (newConstant + self.scrubberWidthLayoutConstraint.constant >= self.scrubberFramesStackView.frame.size.width + self.scrubberFramesStackViewLeadingConstraint.constant + self.scrubberFramesStackViewTrailingConstraint.constant) {
        self.scrubberLeadingLayoutConstraint.constant = self.scrubberFramesStackView.frame.size.width - self.scrubberWidthLayoutConstraint.constant + self.scrubberFramesStackViewLeadingConstraint.constant + self.scrubberFramesStackViewTrailingConstraint.constant;
    } else {
        self.scrubberLeadingLayoutConstraint.constant = newConstant;
    }
    [self.scrubberDragger setNeedsUpdateConstraints];
    
    /* Set new frames for the preview screens */
    if (self.prevOffsetPointX != offsetPoint.x) {
        // At first, detect number of first and last frame
        CGFloat firstFrame = (self.videoSource.framesCount / self.scrubberFramesStackView.frame.size.width) * newConstant;
        CGFloat lastFrame = firstFrame + (self.videoSource.fps * VIDEO_DURATION);
        
        // Check if frames are correct
        if (firstFrame < 0) {
            firstFrame = 0;
        }
        if (lastFrame > self.videoSource.framesCount) {
            lastFrame = self.videoSource.framesCount;
        }

        // At second, set needed frame to the preview image views
        
        [self.previewStartImageView setImageWithCheckingOrientation:[self thumbnailAtFrame:firstFrame]
                                                        orientation:self.videoSource.orientation];
        [self.previewEndImageView setImageWithCheckingOrientation:[self thumbnailAtFrame:lastFrame]
                                                      orientation:self.videoSource.orientation];
        
        // At third, assign selected frames to the videoSource property
        self.videoSource.firstFrameNumber = firstFrame;
        self.videoSource.lastFrameNumber = lastFrame;
    }
    
    // Set current offset point to previous
    self.prevOffsetPointX = offsetPoint.x;
}


#pragma mark - Buttons handlers

- (IBAction)cancelButtonDidTap:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)nextButtonDidTap:(id)sender {
    [self performSegueWithIdentifier:@"toCaptionsSegue" sender:self.videoSource];
}


#pragma mark - Thumbnails getter

- (UIImage *)thumbnailAtFrame:(NSUInteger)frameNumber {
    NSString *frameNumberKey = [NSString stringWithFormat:@"%lu", (unsigned long)frameNumber];
    UIImage *cachedImage = [self.frameCache objectForKey:frameNumberKey];
    
    if (cachedImage != nil) {
        return cachedImage;
    } else {
        NSError *error;
        CGImageRef frameCGImage = [self.imageGenerator copyCGImageAtTime:CMTimeMake(frameNumber, (CGFloat)self.videoSource.fps) actualTime:nil error:&error];
        UIImage *frameImage = [UIImage imageByCroppingVideoFrameCGImage:frameCGImage toSize:CGSizeMake(GIF_SIDE_SIZE, GIF_SIDE_SIZE)];
        CGImageRelease(frameCGImage);
        
        [self.frameCache setObject:frameImage forKey:frameNumberKey];
        
        return frameImage;
    }
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"toCaptionsSegue"]) {
        // Update thumbnail by first frame
        ((VideoSource *)sender).thumbnail = [self thumbnailAtFrame:self.videoSource.firstFrameNumber];
        
        ((CaptionsViewController*)segue.destinationViewController).videoSource = sender;
        ((CaptionsViewController*)segue.destinationViewController).delegate = self.gifListController;
        ((CaptionsViewController*)segue.destinationViewController).creationSource = GifCreationSourceBaked;
        ((CaptionsViewController*)segue.destinationViewController).frameSource = GifFrameSourceGalleryVideo;
    }
}

@end
