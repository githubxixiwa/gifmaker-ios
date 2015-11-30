//
//  GifListTableViewController.h
//  gifmaker
//
//  Created by Sergio on 11/23/15.
//  Copyright © 2015 Cayugasoft. All rights reserved.
//

// Frameworks
#import <UIKit/UIKit.h>

// View Controllers
#import "RecordViewController.h"
#import <QBImagePickerController/QBImagePickerController.h>

@interface GifListTableViewController : UITableViewController <RecordGifDelegate, QBImagePickerControllerDelegate>

@end
