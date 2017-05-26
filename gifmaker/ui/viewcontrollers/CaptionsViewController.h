//
//  CaptionsViewController.h
//  gifmaker
//
//  Created by Sergii Simakhin on 12/3/15.
//  Copyright © 2015 Cayugasoft. All rights reserved.
//

// Frameworks
#import <UIKit/UIKit.h>

// Models
#import "GifElement.h"
#import "VideoSource.h"

// View Controllers
#import "RecordViewController.h"

@interface CaptionsViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIView *blackGifPreviewSublayer;
@property (weak, nonatomic) IBOutlet UIImageView *GIFFirstFramePreviewImageView;
@property (weak, nonatomic) IBOutlet UIView *headerViewBottomLineView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerViewTopConstraint;
@property (weak, nonatomic) IBOutlet UITextField *headerCaptionTextField;
@property (weak, nonatomic) IBOutlet UITextField *footerCaptionTextField;
@property (weak, nonatomic) IBOutlet UILabel *cancelLabel;
@property (weak, nonatomic) IBOutlet UILabel *gifItLabel;
@property (weak, nonatomic) IBOutlet UIView *cardView;
@property (weak, nonatomic) IBOutlet UICollectionView *filtersCollectionView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *filtersView;

@property (weak, nonatomic) IBOutlet UIImageView *previewEndImageView;
@property (weak, nonatomic) IBOutlet UILabel *startTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *endTitleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsViewBottomLayoutContraint;

@property (nonatomic, strong) NSMutableArray<UIImage *> *capturedImages;
@property (nonatomic, strong) UIImage *thumbnail;
@property (nonatomic, strong) VideoSource *videoSource;
@property (nonatomic) GifCreationSource creationSource;
@property (nonatomic) GifFrameSource frameSource;
@property (nonatomic, strong) Filter *activeFilter;
@property (nonatomic, strong) id delegate;

/**
 Index used to determine to which rect of screen we will animate the current card
 */
@property (nonatomic) NSInteger editingGifIndex;

/*! Force set text in header caption */
@property (nonatomic, strong) NSString *headerCaptionTextForced;

/*! Forse set text in footer caption */
@property (nonatomic, strong) NSString *footerCaptionTextForced;

@property (nonatomic, strong) UIImage *videoScrubberScreenshot;

- (CGSize)cardSize;
- (NSInteger)framePreviewSideSize;

@end
