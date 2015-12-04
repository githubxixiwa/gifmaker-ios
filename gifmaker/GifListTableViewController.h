//
//  GifListTableViewController.h
//  gifmaker
//
//  Created by Sergio on 11/23/15.
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

@interface GifListTableViewController : UITableViewController <RecordGifDelegate, QBImagePickerControllerDelegate, MFMessageComposeViewControllerDelegate, GifTableViewСellActionsDelegate>

@end
