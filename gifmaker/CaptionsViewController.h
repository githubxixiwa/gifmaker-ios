//
//  CaptionsViewController.h
//  gifmaker
//
//  Created by Sergio on 12/3/15.
//  Copyright © 2015 Cayugasoft. All rights reserved.
//

// Frameworks
#import <UIKit/UIKit.h>

// View Controllers
#import "RecordViewController.h"

@interface CaptionsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *GIFFirstFramePreviewImageView;
@property (weak, nonatomic) IBOutlet UITextField *headerCaptionTextField;
@property (weak, nonatomic) IBOutlet UITextField *footerCaptionTextField;
@property (weak, nonatomic) IBOutlet UIButton *gifItButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIView *cardView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (nonatomic, strong) NSArray<UIImage *> *capturedImages;
@property (nonatomic, strong) id delegate;

/*! Force set text in header caption */
@property (nonatomic, strong) NSString *headerCaptionTextForced;

/*! Forse set text in footer caption */
@property (nonatomic, strong) NSString *footerCaptionTextForced;

@end
