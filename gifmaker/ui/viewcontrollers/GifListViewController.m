//
//  GifListViewController.m
//  gifmaker
//
//  Created by Sergii Simakhin on 11/23/15.
//  Copyright © 2015 Cayugasoft. All rights reserved.
//

// View Controllers
#import "GifListViewController.h"
#import "CaptionsViewController.h"
#import "VideoScrubberViewController.h"
#import "QBImagePickerControllerWOStatusBar.h"

// Models
#import "VideoSource.h"
#import "FLAnimatedImage.h"
#import "AnalyticsManager.h"

// Categories
#import "UIView+Extras.h"
#import "UIImage+Extras.h"
#import "NSString+Extras.h"
#import "UIImagePickerController+Additions.h"

// Sharing Activities
#import "FacebookShareActivity.h"
#import "IMessageShareActivity.h"
#import "FacebookMessengerShareActivity.h"
#import "SaveVideoActivity.h"

// Custom segues
#import "EditGifSegue.h"
#import "EndEditingSegue.h"
#import "VideoScrubberToGifListSegue.h"
#import "CaptionsCancelsGifFromGalleryToGifList.h"
#import "RecordCancelsToGifListSegue.h"

// Helpers
#import "Macros.h"

@interface GifListViewController()

@property (nonatomic, strong) NSMutableArray<GifElement *> *gifElements;
@property (nonatomic) NSInteger precalculatedCellHeight;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic) NSInteger lastContentOffsetY;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerViewHeightConstraint;

@property (nonatomic) BOOL waitingToScrollTheCell;
@property (nonatomic, strong) NSMutableArray<NSIndexPath *> *indexPathsOfCellsToAnimateAppearance;
@property (nonatomic) BOOL needToFadeInVisibleCellsOnAppear;

/**
 Determine if this view controller is currently on screen
 */
@property (nonatomic) BOOL visible;

@end

@implementation GifListViewController


#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    // Precalculate cell height (iOS zoom mode is also handled by checking native scale)
    self.precalculatedCellHeight = [[UIScreen mainScreen] bounds].size.width * ([UIScreen mainScreen].scale == [UIScreen mainScreen].nativeScale ? 1.24 : 1.28);

    // Preinit date formatter
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateStyle:NSDateFormatterMediumStyle];

    // Set up navigation bar buttons
    self.galleryLabel.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(270));
    self.cameraLabel.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(90));

    [self.galleryLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectMediaSelectionMethod:)]];
    [self.cameraLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shootGIFFromCamera:)]];

    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"backgroundWood1"]]];

    self.lastContentOffsetY = 0;
    self.waitingToScrollTheCell = NO;
    self.indexPathsOfCellsToAnimateAppearance = [NSMutableArray array];
    
    [self setRecordingCardToInitialPosition];

    // Refresh GIF-files (loading them from disk)
    [self refresh];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.visible = YES;
    
    if (self.needToFadeInVisibleCellsOnAppear) {
        self.needToFadeInVisibleCellsOnAppear = NO;
        self.indexPathsOfCellsToAnimateAppearance = [NSMutableArray arrayWithArray:self.tableView.indexPathsForVisibleRows];
        [self.tableView reloadData];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.visible = NO;
    self.indexPathsOfCellsToAnimateAppearance = [NSMutableArray array];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.headerViewBottomLineView.layer.masksToBounds = NO;
    self.headerViewBottomLineView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.headerViewBottomLineView.layer.shadowOffset = CGSizeMake(2.0, 2.0);
    self.headerViewBottomLineView.layer.shadowOpacity = 1.0;
}


#pragma mark - TableView Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

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
    
    if ([self.indexPathsOfCellsToAnimateAppearance containsObject:indexPath]) {
        cell.contentView.alpha = 0;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.visible) {
        if ([self.indexPathsOfCellsToAnimateAppearance containsObject:indexPath]) {
            [UIView animateWithDuration:0.25 animations:^{
                cell.contentView.alpha = 1.0;
            }];
            [self.indexPathsOfCellsToAnimateAppearance removeObject:indexPath];
        }
        
        // Reset transformations, ensure that subviews is visible too
        GifTableViewCell *gifCell = (GifTableViewCell *)cell;
        [gifCell resetTransform];
        [gifCell makeSubviewsVisible];
    } else {
        NSLog(@"Gif list is not visible, so visual preparations on cell will not be handled.");
    }
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.precalculatedCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.precalculatedCellHeight;
}


#pragma mark - Scroll View

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    BOOL scrollingUp = scrollView.contentOffset.y > self.lastContentOffsetY;
    
    /* Several scrolling optimizations to make it smoother */
    if (self.lastContentOffsetY == 0 && scrollView.contentOffset.y == 0) {
        // Last & current offset zero: Optim #0
        self.lastContentOffsetY = scrollView.contentOffset.y;
        return;
    }
    
    if (self.headerViewTopConstraint.constant == HEADER_MINIMUM_HEIGHT - HEADER_DEFAULT_HEIGHT && scrollingUp) {
        // Header already reached off: Optim #1
        self.lastContentOffsetY = scrollView.contentOffset.y;
        return;
    }
    
    if (self.headerViewTopConstraint.constant == HEADER_MINIMUM_HEIGHT && !scrollingUp) {
        // Header already reached on: Optim #2
        self.lastContentOffsetY = scrollView.contentOffset.y;
        return;
    }
    
    if (scrollView.tag == 1) {
        // Scroll view prevented scroll back: Optim #3
        scrollView.tag = 0;
        self.lastContentOffsetY = scrollView.contentOffset.y;
        return;
    }
    
    // Reused blocks
    
    void (^setPreviousScrollOffsetBack)() = ^void() {
        scrollView.tag = 1;
        scrollView.contentOffset = CGPointMake(0, self.lastContentOffsetY);
    };
    
    // Let's begin

    double difference = scrollView.contentOffset.y - self.lastContentOffsetY;
    double newTopConstraintValue = self.headerViewTopConstraint.constant - difference;

    if (scrollingUp) {
        self.waitingToScrollTheCell = NO;
        
        // Scrolling up
        if (newTopConstraintValue < HEADER_MINIMUM_HEIGHT - HEADER_DEFAULT_HEIGHT) {
            newTopConstraintValue = HEADER_MINIMUM_HEIGHT - HEADER_DEFAULT_HEIGHT;
        }

        if (newTopConstraintValue > HEADER_MINIMUM_HEIGHT - HEADER_DEFAULT_HEIGHT) {
            setPreviousScrollOffsetBack();
        }
    } else {
        // Scrolling down
        if (newTopConstraintValue > HEADER_MINIMUM_HEIGHT) {
            newTopConstraintValue = HEADER_MINIMUM_HEIGHT;
        } else if (newTopConstraintValue < HEADER_MINIMUM_HEIGHT - HEADER_DEFAULT_HEIGHT) {
            newTopConstraintValue = HEADER_MINIMUM_HEIGHT - HEADER_DEFAULT_HEIGHT;
        }

        if (newTopConstraintValue < HEADER_MINIMUM_HEIGHT) {
            setPreviousScrollOffsetBack();
        }
    }
    
    self.headerViewTopConstraint.constant = newTopConstraintValue;
    self.lastContentOffsetY = scrollView.contentOffset.y;
}


#pragma mark - Bar Button Items Methods

- (void)shootGIFFromCamera:(id)sender {
    [self performSegueWithIdentifier:@"toRecordSegue" sender:self];
}

- (void)shootGIFFromCameraNotAnimated:(id)sender {
    [self performSegueWithIdentifier:@"toRecordSegue_notAnimated" sender:self];
}

- (void)selectMediaSelectionMethod:(id)sender {
    UIAlertController *mediaSelectionMethodController = [UIAlertController alertControllerWithTitle:@"From which source you'll make your GIF?" message:@"From photos? From video?" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *imageSelectionAction = [UIAlertAction actionWithTitle:@"From 🖼 photos" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self selectMediaFromGallery:GifFrameSourceGalleryPhotos];
    }];
    UIAlertAction *videoSelectionAction = [UIAlertAction actionWithTitle:@"From 🎞 video" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self selectMediaFromGallery:GifFrameSourceGalleryVideo];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) { }];
    
    [mediaSelectionMethodController addAction:imageSelectionAction];
    [mediaSelectionMethodController addAction:videoSelectionAction];
    [mediaSelectionMethodController addAction:cancelAction];
    
    [self presentViewController:mediaSelectionMethodController animated:YES completion:^{ }];
}

- (void)selectMediaFromGallery:(GifFrameSource)frameSource {
    [UIImagePickerController obtainPermissionForMediaSourceType:UIImagePickerControllerSourceTypePhotoLibrary withSuccessHandler:^{
        // Update tableView screenshot (because image picker will be called after)
        self.tableViewScreenshot = [self.tableView screenshot];
        
        // Permissions OK, open photo library to select
        QBImagePickerControllerWOStatusBar *imagePickerController = [[QBImagePickerControllerWOStatusBar alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.allowsMultipleSelection = YES;
        imagePickerController.minimumNumberOfSelection = (frameSource == GifFrameSourceGalleryPhotos) ? GIF_FPS * 1 / 8 : 1;
        imagePickerController.maximumNumberOfSelection = (frameSource == GifFrameSourceGalleryPhotos) ? GIF_FPS * ANIMATION_MAX_DURATION : 1;
        imagePickerController.showsNumberOfSelectedAssets = YES;
        imagePickerController.mediaType = (frameSource == GifFrameSourceGalleryPhotos) ? QBImagePickerMediaTypeImage : QBImagePickerMediaTypeVideo;
        imagePickerController.assetCollectionSubtypes =
            frameSource == GifFrameSourceGalleryPhotos ?
                @[
                  @(PHAssetCollectionSubtypeSmartAlbumUserLibrary), // Camera Roll
                  @(PHAssetCollectionSubtypeAlbumMyPhotoStream), // My Photo Stream
                  @(PHAssetCollectionSubtypeSmartAlbumBursts), // Bursts
                  @(PHAssetCollectionSubtypeSmartAlbumSelfPortraits), // Selfies
                  @(PHAssetCollectionSubtypeSmartAlbumRecentlyAdded), // Recently Added
                  @(PHAssetCollectionSubtypeSmartAlbumScreenshots), // Screenshots
                ]
            :
                @[
                  @(PHAssetCollectionSubtypeSmartAlbumVideos) // Videos
                ]
        ;
        imagePickerController.prompt = frameSource == GifFrameSourceGalleryPhotos ? [NSString stringWithFormat:@"%lu photos min, %lu max. Select them in proper order!", (unsigned long)imagePickerController.minimumNumberOfSelection, (unsigned long)imagePickerController.maximumNumberOfSelection] : @"Select the video for your new GIF 😺";
        
        imagePickerController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentViewController:imagePickerController animated:YES completion:NULL];
    } andFailure:^{
        // Permissions NOT OK, show error alert
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Hey" message:@"App has no permissions to your photo gallery 😿\nPlease open setting and let app access it to continue." preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Open Setting" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    }];
}


#pragma mark - Navigation

/**
 Called when unwind segue is performed (but BEFORE the custom segue animation)

 @param segue performed segue
 */
- (IBAction)backToGifList:(UIStoryboardSegue *)segue {
    if ([segue isKindOfClass:[EndEditingSegue class]]
        || [segue isKindOfClass:[VideoScrubberToGifListSegue class]]
        || [segue isKindOfClass:[CaptionsCancelsGifFromGalleryToGifList class]]
        || [segue isKindOfClass:[RecordCancelsToGifListSegue class]]) {
        // Get list of visible gifs
        self.indexPathsOfCellsToAnimateAppearance = [NSMutableArray arrayWithArray:self.tableView.indexPathsForVisibleRows];
        
        if ([segue isKindOfClass:[EndEditingSegue class]]) {
            // Remove the new/editing gif
            [self.indexPathsOfCellsToAnimateAppearance removeObject:[NSIndexPath
                                                    indexPathForRow:((CaptionsViewController *)segue.sourceViewController).editingGifIndex
                                                    inSection:0]
             ];
        }
        
        // Check if current segue is a returning segue from the recording screen
        if ([segue isKindOfClass:[RecordCancelsToGifListSegue class]]) {
            // Check the need to animate content fading in (if not, clear the index pathes of cells needed to fade in)
            if (self.tableViewScreenshot) {
                self.indexPathsOfCellsToAnimateAppearance = [NSMutableArray array];
            } else {
                self.needToFadeInVisibleCellsOnAppear = YES;
            }
        }
        
        /* When 'tableView:willDisplayCell:forRowAtIndexPath' will be called, all cells who have index path stored in 'self.indexPathsOfCellsToAnimateAppearance' will be displayed with fade-in animation. Typically it's all visible GIF's (one or two fit on screen) except of a new/editing one. */
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"toRecordSegue"]) {
        ((RecordViewController*)segue.destinationViewController).delegate = self;
        
        // Also update table view screenshot before disappering a current VC
        self.tableViewScreenshot = [self.tableView screenshot];
    } else if ([segue.identifier isEqualToString:@"toCaptionsSegue"] || [segue.identifier isEqualToString:@"toCaptionsSegue_noAnimation"]) {
        if ([sender isKindOfClass:[NSArray class]]) {
            // Creating gif from photos
            ((CaptionsViewController*)segue.destinationViewController).capturedImages = sender;
            ((CaptionsViewController*)segue.destinationViewController).delegate = self;
            ((CaptionsViewController*)segue.destinationViewController).creationSource = GifCreationSourceBaked;
            ((CaptionsViewController*)segue.destinationViewController).frameSource = GifFrameSourceGalleryPhotos;
        } else if ([sender isKindOfClass:[VideoSource class]]) {
            // Creating gif from video
            ((CaptionsViewController*)segue.destinationViewController).videoSource = sender;
            ((CaptionsViewController*)segue.destinationViewController).delegate = self;
            ((CaptionsViewController*)segue.destinationViewController).creationSource = GifCreationSourceBaked;
            ((CaptionsViewController*)segue.destinationViewController).frameSource = GifFrameSourceGalleryVideo;
        } else if ([sender isKindOfClass:[GifElement class]]) {
            // Editing gif
            GifElement *editingGif = (GifElement *)sender;
            ((CaptionsViewController*)segue.destinationViewController).capturedImages = [NSMutableArray arrayWithArray:[editingGif getEditableFrames]];
            ((CaptionsViewController*)segue.destinationViewController).delegate = self;
            ((CaptionsViewController*)segue.destinationViewController).headerCaptionTextForced = editingGif.headerCaption;
            ((CaptionsViewController*)segue.destinationViewController).footerCaptionTextForced = editingGif.footerCaption;
            ((CaptionsViewController*)segue.destinationViewController).creationSource = GifCreationSourceEdited;
            ((CaptionsViewController*)segue.destinationViewController).frameSource = editingGif.frameSource;
            ((CaptionsViewController*)segue.destinationViewController).activeFilter = editingGif.filter;
            
            self.headerViewTopConstraintOldValue = self.headerViewTopConstraint.constant;
            NSInteger indexOfEditingGif = [self.gifElements indexOfObject:editingGif];
            ((CaptionsViewController*)segue.destinationViewController).editingGifIndex = indexOfEditingGif;
            
            GifTableViewCell *editingGifCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexOfEditingGif inSection:0]];
            ((CaptionsViewController*)segue.destinationViewController).thumbnail = editingGifCell.gifView.animatedImage.posterImage;
            ((EditGifSegue *)segue).editingGifCell = editingGifCell;
            
            if (indexOfEditingGif - 1 >= 0) {
                ((EditGifSegue *)segue).previousGifCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexOfEditingGif - 1 inSection:0]];
            }
            
            if (indexOfEditingGif + 1 < self.gifElements.count) {
                ((EditGifSegue *)segue).nextGifCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexOfEditingGif + 1 inSection:0]];
            }
        }
    } else if ([segue.identifier isEqualToString:@"toVideoScrubberSegue"]) {
        // Opening video to select exact part of it
        ((VideoScrubberViewController*)segue.destinationViewController).videoSource = sender;
        ((VideoScrubberViewController*)segue.destinationViewController).gifListController = self;
    }
}


#pragma mark - RecordGifDelegate Methods

/*! Refresh UITableView by scanning stored content on disk */
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
    __block BOOL error = false;

    // Configure options for PHAsset->UIImage extractor
    PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
    requestOptions.resizeMode             = PHImageRequestOptionsResizeModeExact;
    requestOptions.deliveryMode           = PHImageRequestOptionsDeliveryModeFastFormat;
    requestOptions.version                = PHImageRequestOptionsVersionCurrent;
    requestOptions.networkAccessAllowed   = YES;
    requestOptions.synchronous            = YES;
    
    void (^dismissViewController)(id) = ^void(id sender) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // If we have no errors, set up next VC in order to see it after image picker being flipped back
            if (!error) {
                if (imagePickerController.mediaType == QBImagePickerMediaTypeImage) {
                    // Show captions editor if GIF source is photos
                    [self performSegueWithIdentifier:@"toCaptionsSegue_noAnimation" sender:sender];
    
                } else if (imagePickerController.mediaType == QBImagePickerMediaTypeVideo) {
                    // Show video part selector if GIF source is video
                    [self performSegueWithIdentifier:@"toVideoScrubberSegue" sender:sender];
                }
            }
            
            // Dismiss image picker controller
            [imagePickerController dismissViewControllerAnimated:YES completion:^{
                if (error) {
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Oops 🤕" message:@"You can't import some photos because they can be compressed in the memory due to lack of it.\nTry to enable network and try again." preferredStyle:UIAlertControllerStyleAlert];
                    [alertController addAction:[UIAlertAction actionWithTitle:@"OK, will try!" style:UIAlertActionStyleDefault handler:nil]];
                    [self presentViewController:alertController animated:YES completion:nil];
                }
            }];
        });
    };
    
    if (imagePickerController.mediaType == QBImagePickerMediaTypeImage) {
        NSMutableArray<UIImage *> *frames = [NSMutableArray array];
        CGFloat sideSize = GifSideSizeFromQuality(GifQualityDefault);
        
        for (PHAsset *asset in assets) {
            if (error) {
                break;
            }
            
            // Photo asset
            CGSize targetSize = (asset.pixelHeight > asset.pixelWidth) ? CGSizeMake(sideSize, CGFLOAT_MAX) : CGSizeMake(CGFLOAT_MAX, sideSize);
            
            // Get UIImage from PHAsset and add it to the 'frames' array
            [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeAspectFit options:requestOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                if (result == nil) {
                    error = YES;
                } else {
                    // Crop center part of the image
                    UIImage *croppedImage = [UIImage imageByCroppingCGImage:result.CGImage toSize:CGSizeMake(sideSize, sideSize)];
                    
                    // Add cropped image to the 'frames' array (with image quality downgrade to reduce GIF size)
                    [frames addObject:[UIImage imageWithData:UIImageJPEGRepresentation(croppedImage, 0.2)]];
                }
            }];
        }
        
        dismissViewController(frames);
        
    } else if (imagePickerController.mediaType == QBImagePickerMediaTypeVideo) {
        [[PHImageManager defaultManager] requestAVAssetForVideo:assets.firstObject options:nil resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
            Float64 videoDuration = CMTimeGetSeconds(asset.duration);
            
            // Check if video duration is lower than 5 seconds (if so, don't let GIF it)
            if (videoDuration < ANIMATION_MAX_DURATION) {
                NSString *alertMessage = [NSString stringWithFormat:@"Video is too short!\nIt must be %ld seconds or longer 😿", (long)ANIMATION_MAX_DURATION];
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Uh oh 😬"
                                                                                         message:alertMessage
                                                                                  preferredStyle:UIAlertControllerStyleAlert];
                [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                [imagePickerController presentViewController:alertController animated:YES completion:nil];
                return;
            }

            VideoSource *videoSource = [[VideoSource alloc] initWithAsset:asset];
            dismissViewController(videoSource);
        }];
    }
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
    if (result == MessageComposeResultSent) {
        [[AnalyticsManager sharedAnalyticsManager] gifSharedViaIMessage];
    }
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
        [[AnalyticsManager sharedAnalyticsManager] gifDeleted];
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

- (void)setRecordingCardToInitialPosition {
    self.recordingCardViewTrailingConstraint.constant = -[UIScreen mainScreen].bounds.size.width;
    self.recordingCardViewLeadingConstraint.constant = [UIScreen mainScreen].bounds.size.width;
}

@end
