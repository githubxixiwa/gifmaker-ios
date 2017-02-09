//
//  GifListViewController.m
//  gifmaker
//
//  Created by Sergio on 11/23/15.
//  Copyright © 2015 Cayugasoft. All rights reserved.
//

#import "Macros.h"

// View Controllers
#import "GifListViewController.h"
#import "CaptionsViewController.h"
#import "VideoScrubberViewController.h"

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

@interface GifListViewController()

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UIButton *galleryButton;

@property (nonatomic, strong) NSMutableArray<GifElement *> *gifElements;
@property (nonatomic) NSInteger precalculatedCellHeight;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (weak, nonatomic) IBOutlet UIView *headerViewBottomLineView;
@property (nonatomic) NSInteger lastContentOffsetY;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerViewTopConstraint;

@property (nonatomic) BOOL waitingToScrollTheCell;
@property (nonatomic) NSInteger waitingCellTopY;
@property (nonatomic) NSInteger waitingCellRowIndex;
@property (nonatomic) NSInteger waitingCellLastYOffset;

@end

@implementation GifListViewController


#pragma mark - Global variables

static double const headerDefaultHeight = 128.0;
static double const headerMinimumHeight = 0.0;
static double const precalculatedCellHeightMultiplier = 1.24;


#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    // Precalculate cell height
    self.precalculatedCellHeight = [[UIScreen mainScreen] bounds].size.width * precalculatedCellHeightMultiplier;

    // Preinit date formatter
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateStyle:NSDateFormatterMediumStyle];

    // Set up navigation bar buttons
    self.galleryButton.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(270));
    self.cameraButton.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(90));

    [self.galleryButton addTarget:self action:@selector(selectMediaSelectionMethod:) forControlEvents:UIControlEventTouchUpInside];
    [self.cameraButton addTarget:self action:@selector(shootGIFFromCamera:) forControlEvents:UIControlEventTouchUpInside];

    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"backgroundWood1"]]];

    self.lastContentOffsetY = 0;
    self.waitingToScrollTheCell = NO;

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

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.headerViewBottomLineView.layer.masksToBounds = NO;
    self.headerViewBottomLineView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.headerViewBottomLineView.layer.shadowOffset = CGSizeMake(2.0, 2.0);
    self.headerViewBottomLineView.layer.shadowOpacity = 1.0;
}


#pragma mark - Table View Delegate Methods

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
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.precalculatedCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.precalculatedCellHeight;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    BOOL scrollingUp = scrollView.contentOffset.y > self.lastContentOffsetY;
    
    //NSLog(@"Content offset: %f, decelerating: %@", scrollView.contentOffset.y, scrollView.isDecelerating ? @"yes" : @"no");

    if (self.lastContentOffsetY == 0 && scrollView.contentOffset.y == 0) {
        // Last & current offset zero: Optim #0
        self.lastContentOffsetY = scrollView.contentOffset.y;
        return;
    }
    
    if (self.headerViewTopConstraint.constant == headerMinimumHeight - headerDefaultHeight && scrollingUp) {
        // Header already reached off: Optim #1
        self.lastContentOffsetY = scrollView.contentOffset.y;
        return;
    }
    
    if (self.headerViewTopConstraint.constant == headerMinimumHeight && !scrollingUp) {
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
        // SCR UP
        if (newTopConstraintValue < headerMinimumHeight - headerDefaultHeight) {
            newTopConstraintValue = headerMinimumHeight - headerDefaultHeight;
        }

        if (newTopConstraintValue > headerMinimumHeight - headerDefaultHeight) {
            setPreviousScrollOffsetBack();
        }
    } else {
        /*
        if (self.headerViewTopConstraint.constant == -headerDefaultHeight && self.gifElements.count > 0) {
            NSIndexPath *firstVisibleCellIndexPath = [self.tableView indexPathForCell:self.tableView.visibleCells.firstObject];
            
            if (firstVisibleCellIndexPath.row > 0) {
                void (^nullateWaitingCell)() = ^void() {
                    self.waitingToScrollTheCell = NO;
                    self.waitingCellLastYOffset = -1;
                    self.waitingCellTopY = -1;
                    self.waitingCellRowIndex = -1;
                    backFromWaitingCell = YES;
                };
                
                CGRect firstVisibleCellRect = [self.tableView rectForRowAtIndexPath:firstVisibleCellIndexPath];
                NSInteger firstVisibleCellYOffset = scrollView.contentOffset.y - (firstVisibleCellIndexPath.row * self.precalculatedCellHeight);
                NSInteger firstVisibleCellCurrentOffsetToTop = firstVisibleCellRect.origin.y - (firstVisibleCellIndexPath.row * self.precalculatedCellHeight);
                
                BOOL abort = NO;
                
                if (self.waitingToScrollTheCell) {
                    if (firstVisibleCellIndexPath.row != self.waitingCellRowIndex) {
                        if (firstVisibleCellYOffset > self.waitingCellLastYOffset) {
                            //NSLog(@"Changing ownership abort");
                            abort = YES;
                            nullateWaitingCell();
                        } else {
                            //NSLog(@"Changing ownership");
                            self.waitingCellRowIndex = firstVisibleCellIndexPath.row;
                            self.waitingCellTopY = firstVisibleCellRect.origin.y;
                        }
                    }
                }
                
                if (!abort) {
                    if (self.waitingToScrollTheCell && firstVisibleCellYOffset > firstVisibleCellCurrentOffsetToTop) {
                        self.waitingCellLastYOffset = firstVisibleCellYOffset;
                        
                        //NSLog(@"QRT (fvcyf: %ld)", (long)firstVisibleCellYOffset);
                        self.lastContentOffsetY = scrollView.contentOffset.y;
                        return;
                    } else if (firstVisibleCellYOffset > firstVisibleCellCurrentOffsetToTop) {
                        self.waitingToScrollTheCell = YES;
                        self.waitingCellRowIndex = firstVisibleCellIndexPath.row;
                        self.waitingCellTopY = firstVisibleCellRect.origin.y;
                        self.waitingCellLastYOffset = firstVisibleCellYOffset;
                        
                        //NSLog(@"aer (fvcyf: %ld)", (long)firstVisibleCellYOffset);
                        self.lastContentOffsetY = scrollView.contentOffset.y;
                        return;
                    } else if (firstVisibleCellYOffset == firstVisibleCellCurrentOffsetToTop) {
                        nullateWaitingCell();
                        //NSLog(@"abe!");
                    }
                }
            }
        }
        */
        
        // SCR DOWN
        if (newTopConstraintValue > headerMinimumHeight) {
            newTopConstraintValue = headerMinimumHeight;
        } else if (newTopConstraintValue < headerMinimumHeight - headerDefaultHeight) {
            newTopConstraintValue = headerMinimumHeight - headerDefaultHeight;
        }

        if (newTopConstraintValue < headerMinimumHeight) {
            setPreviousScrollOffsetBack();
        }
    }
    
    /* Header's off screen percentage
    double percentage = 100 - ((newTopConstraintValue / (headerMinimumHeight - headerDefaultHeight)) * 100);
     */
    
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
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"cancel");
    }];
    
    [mediaSelectionMethodController addAction:imageSelectionAction];
    [mediaSelectionMethodController addAction:videoSelectionAction];
    [mediaSelectionMethodController addAction:cancelAction];
    
    [self presentViewController:mediaSelectionMethodController animated:YES completion:^{
        //
    }];
}

- (void)selectMediaFromGallery:(GifFrameSource)frameSource {
    [UIImagePickerController obtainPermissionForMediaSourceType:UIImagePickerControllerSourceTypePhotoLibrary withSuccessHandler:^{
        // Permissions OK, open photo library to select
        QBImagePickerController *imagePickerController = [QBImagePickerController new];
        imagePickerController.delegate = self;
        imagePickerController.allowsMultipleSelection = YES;
        imagePickerController.minimumNumberOfSelection = (frameSource == GifFrameSourceGalleryPhotos) ? GIF_FPS * 1 / 8 : 1;
        imagePickerController.maximumNumberOfSelection = (frameSource == GifFrameSourceGalleryPhotos) ? GIF_FPS * VIDEO_DURATION : 1;
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"toRecordSegue"]) {
        ((RecordViewController*)segue.destinationViewController).delegate = self;
    } else if ([segue.identifier isEqualToString:@"toCaptionsSegue"]) {
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
        }
    } else if ([segue.identifier isEqualToString:@"toVideoScrubberSegue"]) {
        ((VideoScrubberViewController*)segue.destinationViewController).videoSource = sender;
        ((VideoScrubberViewController*)segue.destinationViewController).gifListController = self;
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
    __block BOOL error = false;

    // Configure options for PHAsset->UIImage extractor
    PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
    requestOptions.resizeMode             = PHImageRequestOptionsResizeModeExact;
    requestOptions.deliveryMode           = PHImageRequestOptionsDeliveryModeFastFormat;
    requestOptions.version                = PHImageRequestOptionsVersionCurrent;
    requestOptions.networkAccessAllowed   = YES;
    requestOptions.synchronous            = YES;

    //TODO: make a preloader when photos are loading from iCloud? Because for now UI can stuck in this case (weird!).
    
    void (^dismissViewController)(id) = ^void(id sender) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [imagePickerController dismissViewControllerAnimated:YES completion:^{
                if (error) {
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Oops 🤕" message:@"You can't import some photos because they can be compressed in the memory due to lack of it.\nTry to enable network and try again." preferredStyle:UIAlertControllerStyleAlert];
                    [alertController addAction:[UIAlertAction actionWithTitle:@"OK, will try!" style:UIAlertActionStyleDefault handler:nil]];
                    [self presentViewController:alertController animated:YES completion:nil];
                } else {
                    [self performSegueWithIdentifier:@"toCaptionsSegue" sender:sender];
                }
            }];
        });
    };
    
    if (imagePickerController.mediaType == QBImagePickerMediaTypeImage) {
        NSMutableArray<UIImage *> *frames = [NSMutableArray array];
        
        for (PHAsset *asset in assets) {
            if (error) {
                break;
            }
            
            // Photo asset
            CGSize targetSize = (asset.pixelHeight > asset.pixelWidth) ? CGSizeMake(GIF_SIDE_SIZE, CGFLOAT_MAX) : CGSizeMake(CGFLOAT_MAX, GIF_SIDE_SIZE);
            
            // Get UIImage from PHAsset and add it to the 'frames' array
            [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeAspectFit options:requestOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                if (result == nil) {
                    error = YES;
                } else {
                    // Crop center part of the image
                    UIImage *croppedImage = [UIImage imageByCroppingCGImage:result.CGImage toSize:CGSizeMake(GIF_SIDE_SIZE, GIF_SIDE_SIZE)];
                    
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
            if (videoDuration < VIDEO_DURATION) {
                NSString *alertMessage = [NSString stringWithFormat:@"Video is too short!\nIt must be %ld seconds or longer 😿", (long)VIDEO_DURATION];
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Uh oh 😬"
                                                                                         message:alertMessage
                                                                                  preferredStyle:UIAlertControllerStyleAlert];
                [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                [imagePickerController presentViewController:alertController animated:YES completion:nil];
                return;
            }
            
            NSArray *movieTracks = [asset tracksWithMediaType:AVMediaTypeVideo];
            AVAssetTrack *movieTrack = [movieTracks firstObject];
            
            AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
            imageGenerator.requestedTimeToleranceAfter = kCMTimeZero;
            imageGenerator.requestedTimeToleranceBefore = kCMTimeZero;
            imageGenerator.appliesPreferredTrackTransform = YES;
            
            Float64 framesCount = videoDuration * movieTrack.nominalFrameRate;
            
            // Extract first frame from the video to save a thumbnail
            NSError *error;
            CGImageRef firstFrame = [imageGenerator copyCGImageAtTime:CMTimeMake(0, movieTrack.nominalFrameRate) actualTime:nil error:&error];
            UIImage *firstFrameImage = [UIImage imageByCroppingVideoFrameCGImage:firstFrame toSize:CGSizeMake(GIF_SIDE_SIZE, GIF_SIDE_SIZE)];
            CGImageRelease(firstFrame);
            
            VideoSource *videoSource = [[VideoSource alloc] init];
            videoSource.fps = movieTrack.nominalFrameRate + 1;
            videoSource.duration = videoDuration;
            videoSource.framesCount = framesCount;
            videoSource.thumbnail = firstFrameImage;
            videoSource.asset = asset;
            videoSource.orientation = [self extractOrientationFromVideoTrack:movieTrack];
            
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

- (UIInterfaceOrientation)extractOrientationFromVideoTrack:(AVAssetTrack *)videoTrack {
    CGSize size = [videoTrack naturalSize];
    CGAffineTransform transform = [videoTrack preferredTransform];
    
    if (size.width == transform.tx && size.height == transform.ty)
        return UIInterfaceOrientationLandscapeRight;
    else if (transform.tx == 0 && transform.ty == 0)
        return UIInterfaceOrientationLandscapeLeft;
    else if (transform.tx == 0 && transform.ty == size.width)
        return UIInterfaceOrientationPortraitUpsideDown;
    else
        return UIInterfaceOrientationPortrait;
}

@end
