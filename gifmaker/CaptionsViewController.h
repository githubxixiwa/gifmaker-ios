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

@property (strong, nonatomic) IBOutlet UIImageView *GIFFirstFramePreviewImageView;
@property (strong, nonatomic) IBOutlet UITextField *headerCaptionTextField;
@property (strong, nonatomic) IBOutlet UITextField *footerCaptionTextField;
@property (strong, nonatomic) IBOutlet UILabel *instructionsLabel;

@property (nonatomic, strong) NSArray<UIImage *> *capturedImages;
@property (nonatomic, strong) id delegate;

@end
