//
//  GifListViewController.h
//  gifmaker
//
//  Created by Sergii Simakhin on 11/23/15.
//  Copyright © 2015 Cayugasoft. All rights reserved.
//

#define HEADER_DEFAULT_HEIGHT 128.0
#define HEADER_MINIMUM_HEIGHT 0.0

// Frameworks
#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <QBImagePickerController/QBImagePickerController.h>

// View Controllers
#import "RecordViewController.h"

// Models
#import "GifTableViewCell.h"
#import "GifManager.h"

@interface GifListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, RecordGifDelegate, QBImagePickerControllerDelegate, MFMessageComposeViewControllerDelegate, GifTableViewСellActionsDelegate>

- (void)selectMediaFromGallery:(GifFrameSource)frameSource;
- (void)shootGIFFromCameraNotAnimated:(id)sender;
- (void)shootGIFFromCamera:(id)sender;
- (void)setRecordingCardToInitialPosition;

@end

@interface GifListViewController()

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *galleryLabel;
@property (weak, nonatomic) IBOutlet UILabel *cameraLabel;
@property (weak, nonatomic) IBOutlet UIView *headerViewBottomLineView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerViewTopConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewTopConstraint;

@property (weak, nonatomic) IBOutlet UIView *recordingCardView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *recordingCardViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *recordingCardViewTrailingConstraint;

@property (nonatomic) CGFloat headerViewTopConstraintOldValue;
@property (strong, nonatomic) UIImage *tableViewScreenshot;

@end
