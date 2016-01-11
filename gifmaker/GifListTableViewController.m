//
//  GifListTableViewController.m
//  gifmaker
//
//  Created by Sergio on 11/23/15.
//  Copyright © 2015 Cayugasoft. All rights reserved.
//

#define GalleryButtonTAG 300
#define CameraButtonTAG 301

// View Controllers
#import "GifListTableViewController.h"
#import "CaptionsViewController.h"

// Models
#import "GifManager.h"
#import "FLAnimatedImage.h"

// Categories
#import "UIImage+Extras.h"
#import "NSString+Extras.h"

// Sharing Activities
#import "FacebookShareActivity.h"
#import "IMessageShareActivity.h"
#import "FacebookMessengerShareActivity.h"
#import "SaveVideoActivity.h"

@interface GifListTableViewController()

@property (nonatomic, strong) NSMutableArray<GifElement *> *gifElements;
@property (nonatomic) NSInteger precalculatedCellHeight;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation GifListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Precalculate cell height
    self.precalculatedCellHeight = [[UIScreen mainScreen] bounds].size.width * 1.24;
    
    // Preinit date formatter
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    
    // Set up navigation bar buttons
    UIButton *galleryButton = [self.tableView viewWithTag:GalleryButtonTAG];
    UIButton *cameraButton = [self.tableView viewWithTag:CameraButtonTAG];
    
    galleryButton.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(270));
    cameraButton.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(90));
    
    [galleryButton addTarget:self action:@selector(selectImagesFromGallery:) forControlEvents:UIControlEventTouchUpInside];
    [cameraButton addTarget:self action:@selector(shootGIFFromCamera:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.tableView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"backgroundWood1"]]];
    
    // Refresh GIF-files from storage
    [self refresh];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - Table View Delegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.gifElements.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GifTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier" forIndexPath:indexPath];
    GifElement *gifElement = self.gifElements[indexPath.row];
    [cell.editButton setEnabled:gifElement.editable];
    cell.gifView.animatedImage = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfURL:gifElement.gifURL]];
    cell.postedDateLabel.text = [NSString stringWithFormat:@"posted with love on %@", [self.dateFormatter stringFromDate:gifElement.datePosted]];

    cell.delegate = self;
    cell.tag = indexPath.row;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.precalculatedCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.precalculatedCellHeight;
}


#pragma mark - Bar Button Items Methods

- (void)shootGIFFromCamera:(id)sender {
    [self performSegueWithIdentifier:@"toRecordSegue" sender:self];
}

- (void)selectImagesFromGallery:(id)sender {
    QBImagePickerController *imagePickerController = [QBImagePickerController new];
    imagePickerController.delegate = self;
    imagePickerController.allowsMultipleSelection = YES;
    imagePickerController.minimumNumberOfSelection = GIF_FPS * 1 / 2; //0.5 second GIF is a minimum duration
    imagePickerController.maximumNumberOfSelection = GIF_FPS * VIDEO_DURATION;
    imagePickerController.showsNumberOfSelectedAssets = YES;
    imagePickerController.mediaType = QBImagePickerMediaTypeImage;
    imagePickerController.prompt = [NSString stringWithFormat:@"%lu photos min, %lu max. Select photos in proper order!", (unsigned long)imagePickerController.minimumNumberOfSelection, (unsigned long)imagePickerController.maximumNumberOfSelection];
    
    [self presentViewController:imagePickerController animated:YES completion:NULL];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"toRecordSegue"]) {
        ((RecordViewController*)segue.destinationViewController).delegate = self;
    } else if ([segue.identifier isEqualToString:@"toCaptionsSegue"]) {
        GifElement *editingGif = (GifElement *)sender;
        ((CaptionsViewController*)segue.destinationViewController).capturedImages = [editingGif getEditableFrames];
        ((CaptionsViewController*)segue.destinationViewController).delegate = self;
        ((CaptionsViewController*)segue.destinationViewController).headerCaptionTextForced = editingGif.headerCaption;
        ((CaptionsViewController*)segue.destinationViewController).footerCaptionTextForced = editingGif.footerCaption;
    }
}


#pragma mark - RecordGifDelegate Methods

- (void)refresh {
    self.gifElements = [NSMutableArray array];
    
    // Load GIF-metadata files
    NSArray<NSURL *> *metadataFilesFromStorage = [GifManager localMetadataFilesPaths];
    for (NSURL *metadataFileURL in metadataFilesFromStorage) {
        GifElement *gifElement = [[GifElement alloc] initWithMetadataFile:metadataFileURL];
        [self.gifElements addObject:gifElement];
    }
    
    NSSortDescriptor *dateDescriptor = [NSSortDescriptor
                                        sortDescriptorWithKey:@"datePosted"
                                        ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:dateDescriptor];
    self.gifElements = [NSMutableArray arrayWithArray:[self.gifElements sortedArrayUsingDescriptors:sortDescriptors]];
    
    [self.tableView reloadData];
    [self scrollToTop];
}


#pragma mark - QBImagePickerControllerDelegate Methods

- (void)qb_imagePickerController:(QBImagePickerController *)imagePickerController didFinishPickingAssets:(NSArray *)assets {
    NSMutableArray<UIImage *> *frames = [NSMutableArray array];
    
    // Configure options for PHAsset->UIImage extractor
    PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
    requestOptions.resizeMode   = PHImageRequestOptionsResizeModeExact;
    requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
    requestOptions.synchronous  = YES;
    
    for (PHAsset *asset in assets) {
        CGSize targetSize = (asset.pixelHeight > asset.pixelWidth) ? CGSizeMake(GIF_SIDE_SIZE, CGFLOAT_MAX)
                                                                   : CGSizeMake(CGFLOAT_MAX, GIF_SIDE_SIZE);
        
        // Get UIImage from PHAsset and add it to the 'frames' array
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeAspectFit options:requestOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            // Crop center part of the image
            UIImage *croppedImage = [UIImage imageByCroppingCGImage:result.CGImage toSize:CGSizeMake(GIF_SIDE_SIZE, GIF_SIDE_SIZE)];
            
            // Add cropped image to the 'frames' array (with image quality downgrade to reduce GIF size)
            [frames addObject:[UIImage imageWithData:UIImageJPEGRepresentation(croppedImage, 0.2)]];
        }];
    }
    
    [imagePickerController dismissViewControllerAnimated:YES completion:^{
        [self performSegueWithIdentifier:@"toCaptionsSegue" sender:frames];
    }];
}

- (void)qb_imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController {
    [imagePickerController dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - GifTableViewCellActionsDelegate Methods

- (void)shareButtonDidTapHandler:(NSInteger)index {
    // Prepare custom share buttons
    
    IMessageShareActivity *imessageShareActivity = [[IMessageShareActivity alloc] init];
    imessageShareActivity.gifData = [NSData dataWithContentsOfURL:[self.gifElements[index] gifURL]];
    imessageShareActivity.viewController = self;
    
    FacebookShareActivity *facebookShareActivity = [[FacebookShareActivity alloc] init];
    facebookShareActivity.gifURL = [self.gifElements[index] gifURL];
    facebookShareActivity.showInViewController = self;
    
    FacebookMessengerShareActivity *facebookMessengerShareActivity = [[FacebookMessengerShareActivity alloc] init];
    facebookMessengerShareActivity.gifData = [NSData dataWithContentsOfURL:[self.gifElements[index] gifURL]];
    facebookMessengerShareActivity.showInViewController = self;
    
    SaveVideoActivity *saveVideoActivity = [[SaveVideoActivity alloc] init];
    saveVideoActivity.gifElement = self.gifElements[index];
    
    // Make sharing controller with our share buttons
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc]
                                                        initWithActivityItems:@[]
                                                        applicationActivities:@[imessageShareActivity,
                                                                                facebookShareActivity,
                                                                                facebookMessengerShareActivity,
                                                                                saveVideoActivity]];
    
    // Exclude all system's sharing services (use only our ones)
    NSArray *excludeActivities = @[UIActivityTypeAirDrop,
                                   UIActivityTypePrint,
                                   UIActivityTypeAssignToContact,
                                   UIActivityTypeAddToReadingList,
                                   UIActivityTypePostToFlickr,
                                   UIActivityTypePostToVimeo,
                                   UIActivityTypeCopyToPasteboard,
                                   UIActivityTypeOpenInIBooks,
                                   UIActivityTypePostToWeibo,
                                   UIActivityTypePostToTwitter,
                                   UIActivityTypeMail,
                                   UIActivityTypePostToFacebook,
                                   UIActivityTypePostToTencentWeibo,
                                   UIActivityTypeSaveToCameraRoll];
    
    activityViewController.excludedActivityTypes = excludeActivities;
    
    // Present sharing controller to the user
    [self.navigationController presentViewController:activityViewController
                                       animated:YES
                                     completion:^{
                                         // Do something on completion
                                     }];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)editButtonDidTapHandler:(NSInteger)index {
    // Check for editable images presense
    NSArray<UIImage *> *images = [self.gifElements[index] getEditableFrames];
    if (images) {
        [self performSegueWithIdentifier:@"toCaptionsSegue" sender:self.gifElements[index]];
    } else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Oops!" message:@"It seems that GIF's sources can't be found. Maybe someone removed them via iTunes?" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Oh no!" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)deleteMediaDidTapHandler:(NSInteger)index {
    // Ask user if he really want to remove GIF
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Oh no!" message:@"Do you really want to delete this GIF?" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Yes!" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self.gifElements[index] removeFromDisk];
        [self refresh];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Oops, no" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}


#pragma mark - Helpers

- (void)scrollToTop {
    if ([self numberOfSectionsInTableView:self.tableView] > 0 && [self.tableView numberOfRowsInSection:0] > 0) {
        NSIndexPath *top = [NSIndexPath indexPathForRow:NSNotFound inSection:0];
        [self.tableView scrollToRowAtIndexPath:top atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

@end
