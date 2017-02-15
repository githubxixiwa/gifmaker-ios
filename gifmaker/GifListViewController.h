//
//  GifListViewController.h
//  gifmaker
//
//  Created by Sergii Simakhin on 11/23/15.
//  Copyright © 2015 Cayugasoft. All rights reserved.
//

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

@end
