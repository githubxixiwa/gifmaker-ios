//
//  VideoScrubberViewController.h
//  gifmaker
//
//  Created by Sergii Simakhin on 1/17/17.
//  Copyright © 2017 Cayugasoft. All rights reserved.
//

// Frameworks
#import <UIKit/UIKit.h>

// View Controllers
#import "GifListViewController.h"

// Models
#import "VideoSource.h"

@interface VideoScrubberViewController : UIViewController

// UI elements
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

@property (weak, nonatomic) IBOutlet UIImageView *previewStartImageView;
@property (weak, nonatomic) IBOutlet UIImageView *previewEndImageView;

@property (weak, nonatomic) IBOutlet UIView *scrubberCinemaTapeView;

@property (weak, nonatomic) IBOutlet UIStackView *scrubberFramesStackView;
@property (weak, nonatomic) IBOutlet UIImageView *scrubberFrame1;
@property (weak, nonatomic) IBOutlet UIImageView *scrubberFrame2;
@property (weak, nonatomic) IBOutlet UIImageView *scrubberFrame3;
@property (weak, nonatomic) IBOutlet UIImageView *scrubberFrame4;
@property (weak, nonatomic) IBOutlet UIImageView *scrubberFrame5;
@property (weak, nonatomic) IBOutlet UIImageView *scrubberFrame6;

@property (weak, nonatomic) IBOutlet UIView *scrubberDragger;
@property (weak, nonatomic) IBOutlet UIView *scrubberDraggerBackgroundView;
@property (weak, nonatomic) IBOutlet UIView *scrubberDraggerContentView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrubberFramesStackViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrubberFramesStackViewTrailingConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrubberWidthLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrubberLeadingLayoutConstraint;

// Stored properties
@property (nonatomic, strong) VideoSource *videoSource;
@property (nonatomic, strong) GifListViewController *gifListController;

@end
