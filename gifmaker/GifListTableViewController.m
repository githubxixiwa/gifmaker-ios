//
//  GifListTableViewController.m
//  gifmaker
//
//  Created by Sergio on 11/23/15.
//  Copyright © 2015 Cayugasoft. All rights reserved.
//

// Frameworks
#import <FBSDKMessengerShareKit/FBSDKMessengerShareKit.h>

// View Controllers
#import "GifListTableViewController.h"
#import "CaptionsViewController.h"

// Models
#import "GifManager.h"
#import "FLAnimatedImage.h"

// Categories
#import "UIImage+Extras.h"
#import "NSString+Extras.h"

@interface GifListTableViewController()

@property (nonatomic, strong) NSMutableArray<GifElement *> *gifElements;

@end

@implementation GifListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"💥GifMaker!💥";
    
    // Set up navigation bar buttons
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(shootGIFFromCamera:)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(selectImagesFromGallery:)];
    
    //self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    // Refresh GIF-files from storage
    [self refresh];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}


#pragma mark - Table View Delegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.gifElements.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GifTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier" forIndexPath:indexPath];
    cell.gifView.animatedImage = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfURL:[self.gifElements[indexPath.row] gifURL]]];
    cell.delegate = self;
    cell.tag = indexPath.row;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [[UIScreen mainScreen] bounds].size.width + 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [[UIScreen mainScreen] bounds].size.width + 60;
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
        ((CaptionsViewController*)segue.destinationViewController).capturedImages = sender;
        ((CaptionsViewController*)segue.destinationViewController).delegate = self;
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

- (void)shareViaiMessageDidTapHandler:(NSInteger)index {
    NSData *gifData = [NSData dataWithContentsOfURL:[self.gifElements[index] gifURL]];
    
    // Share via iMessage
    if ([MFMessageComposeViewController canSendText]) {
        MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
        [messageController setMessageComposeDelegate:self];
        [messageController setRecipients:@[]];
        [messageController setBody:@"Shared with GifMaker!"];
        [messageController addAttachmentData:[NSData dataWithData:gifData] typeIdentifier:@"public.movie" filename:@"animation.gif"];
        [self presentViewController:messageController animated:YES completion:nil];
    } else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:@"Can't share via iMessage!" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [self dismissViewControllerAnimated:YES completion:nil];
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

- (void)shareToGalleryDidTapHandler:(NSInteger)index {
    [self.gifElements[index] saveToGalleryAsVideo];
}

- (void)shareViaFBMessengerDidTapHandler:(NSInteger)index {
    NSData *gifData = [NSData dataWithContentsOfURL:[self.gifElements[index] gifURL]];
    [FBSDKMessengerSharer shareAnimatedGIF:gifData withOptions:nil];
}

@end
