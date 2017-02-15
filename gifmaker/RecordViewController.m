//
//  RecordViewController.m
//  gifmaker
//
//  Created by Sergii Simakhin on 11/24/15.
//  Copyright © 2015 Cayugasoft. All rights reserved.
//

// View Controllers
#import "RecordViewController.h"
#import "CaptionsViewController.h"

// Models
#import "GifManager.h"

// Categories
#import "UIView+Extras.h"
#import "UIImage+Extras.h"
#import "NSString+Extras.h"

// Helpers
#import "Macros.h"

@interface RecordViewController ()

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureDevice *currentCaptureDevice;
@property (nonatomic, strong) NSMutableArray<UIImage *> *capturedImages;
@property (nonatomic) BOOL recording;
@property (nonatomic) BOOL frontCameraIsActive;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation RecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.capturedImages = [NSMutableArray array];
    self.recording = NO;
    self.frontCameraIsActive = YES;
    
    self.cancelButton.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(270));
    self.nextButton.transform   = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(90));
    
    [self.circularProgressView addTarget:self action:@selector(capture:) forControlEvents:UIControlEventTouchDown];
    [self.circularProgressView addTarget:self action:@selector(pauseCapturing:) forControlEvents:UIControlEventTouchUpInside];
    [self.circularProgressView setProgressTintColor:[UIColor redColor]];//RGB(199, 156, 106)];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"backgroundWood1"]]];
    [self.cardView applyShadow];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Init capture session
    self.captureSession = [[AVCaptureSession alloc] init];
    
    AVCaptureDevice *device = [self frontCamera];
    
    if (!device) {
        [self displayCameraErrorAlert];
        return;
    }
    
    NSError *error;
    AVCaptureDeviceInput *input = [[AVCaptureDeviceInput alloc] initWithDevice:device
                                                                         error:&error];
    if (error) {
        NSLog(@"Error adding new AVCaptureDeviceInput!");
        [self displayCameraErrorAlert];
        return;
    }
    
    if (input) {
        [self.captureSession addInput:input];
    } else {
        NSLog(@"Couldn't initialize device input: %@", error);
        [self displayCameraErrorAlert];
        return;
    }
    
    // Set output
    AVCaptureVideoDataOutput *captureOutput = [[AVCaptureVideoDataOutput alloc] init];
    [captureOutput setSampleBufferDelegate:self queue:dispatch_queue_create("cameraFramesQueue", DISPATCH_QUEUE_SERIAL)];
    [captureOutput setAlwaysDiscardsLateVideoFrames:YES];
    
    [self.captureSession addOutput:captureOutput];
    [self.captureSession setSessionPreset:AVCaptureSessionPreset640x480];
    
    // Set preview layer
    AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
    previewLayer.frame = self.cameraPreviewUIView.bounds;
    [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [self.cameraPreviewUIView.layer addSublayer:previewLayer];
    
    // Start the capture session
    self.currentCaptureDevice = device;
    [self.captureSession startRunning];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.timer invalidate];
}


#pragma mark - AVFoundation methods

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    // [One-time case] Control camera preferences: FPS, mirroring, orientation, stabilization
    AVCaptureDevice *device = self.currentCaptureDevice;
    CMTime frameDuration = CMTimeMake(1, GIF_FPS);
    if (!(CMTIME_COMPARE_INLINE(device.activeVideoMaxFrameDuration, ==, frameDuration)
        && CMTIME_COMPARE_INLINE(device.activeVideoMinFrameDuration, ==, frameDuration))) {
        // Configure camera to use 16 FPS (GIF Gold Standard)
        NSError *errorSettingFramerate;
        
        NSArray *supportedFrameRateRanges = [device.activeFormat videoSupportedFrameRateRanges];
        BOOL frameRateSupported = NO;
        for (AVFrameRateRange *range in supportedFrameRateRanges) {
            if (CMTIME_COMPARE_INLINE(frameDuration, >=, range.minFrameDuration) &&
                CMTIME_COMPARE_INLINE(frameDuration, <=, range.maxFrameDuration)) {
                frameRateSupported = YES;
            }
        }
        
        if (frameRateSupported && [device lockForConfiguration:&errorSettingFramerate]) {
            [device setActiveVideoMaxFrameDuration:frameDuration];
            [device setActiveVideoMinFrameDuration:frameDuration];
            [device unlockForConfiguration];
        }
        
        // Set cinematic stabilization
        AVCaptureVideoStabilizationMode stabilizationMode = AVCaptureVideoStabilizationModeCinematic;
        if ([device.activeFormat isVideoStabilizationModeSupported:stabilizationMode]) {
            [connection setPreferredVideoStabilizationMode:stabilizationMode];
        }
        
        // Set camera orientation
        [connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
    }
    
    // Set camera mirrored (to have a "what you see is what you got" result)
    [connection setVideoMirrored:self.frontCameraIsActive];
    
    // Update progress bar state
    if (!self.recording || self.capturedImages.count == GIF_FPS * VIDEO_DURATION) {
        if (self.capturedImages.count == GIF_FPS * VIDEO_DURATION) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.circularProgressView setAlpha:0.3];
            });
        }
        return;
    } else {
        CGFloat progress = self.capturedImages.count / ((GIF_FPS * VIDEO_DURATION) - 1);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationItem.rightBarButtonItem setEnabled:YES];
            [self.circularProgressView setProgress:progress animated:YES];
        });
    }
    
    // Convert CMSampleBufferRef -> CGImageRef
    CVImageBufferRef cvImage = CMSampleBufferGetImageBuffer(sampleBuffer);
    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:cvImage];
    
    CIContext *temporaryContext = [CIContext contextWithOptions:nil];
    CGImageRef videoImage = [temporaryContext
                             createCGImage:ciImage
                             fromRect:CGRectMake(0, 0,
                                                 CVPixelBufferGetWidth(cvImage),
                                                 CVPixelBufferGetHeight(cvImage))];
    
    // Crop square center from the photo
    UIImage *croppedImage = [UIImage imageByCroppingCGImage:videoImage toSize:GifSizeFromQuality(GifQualityDefault)];
    
    // Add captured frame to 'capturedImages' array
    [self.capturedImages addObject:croppedImage];
    
    // Clean memory
    CGImageRelease(videoImage);
}


#pragma mark - Camera

- (AVCaptureDevice *)frontCamera {
    return [self getCameraByPosition:AVCaptureDevicePositionFront];
}

- (AVCaptureDevice *)backCamera {
    return [self getCameraByPosition:AVCaptureDevicePositionBack];
}

- (AVCaptureDevice *)getCameraByPosition:(AVCaptureDevicePosition)devicePosition {
    for (AVCaptureDevice *device in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
        if ([device position] == devicePosition) {
            return device;
        }
    }
    
    return [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
}


#pragma mark - Buttons handlers

- (IBAction)cancelButtonDidTap:(id)sender {
    void (^performPop)() = ^void() {
        [self.captureSession stopRunning];
        [self.navigationController popViewControllerAnimated:YES];
    };
    
    if (self.capturedImages.count > 0) {
        // Double check canceling by asking user
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Are you sure?!" message:@"You'll lost your captured video 😿" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Yes, I want to go back" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            performPop();
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Oops, no 😬" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        performPop();
    }
}

- (IBAction)nextButtonDidTap:(id)sender {
    if (self.capturedImages.count > 0) {
        [self.captureSession stopRunning];
        [self performSegueWithIdentifier:@"toCaptionsSegue" sender:self];
    } else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Hey!" message:@"Shoot something first 😸\nPress and hold circle button at the bottom of the screen." preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Okay, got it" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)capture:(id)sender {
    self.recording = YES;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
    NSLog(@"Capturing");
}

- (void)pauseCapturing:(id)sender {
    self.recording = NO;
    [self.timer invalidate];
    NSLog(@"Paused. Captured %lu frames", (unsigned long)self.capturedImages.count);
}

// Check if user reached max time of record
- (void)timerFired:(id)sender {
    if (self.capturedImages.count >= GIF_FPS * VIDEO_DURATION) {
        [self nextButtonDidTap:sender];
    }
}

- (IBAction)changeCameraButtonDidTap:(id)sender {
    // Pause capturing when user changed the camera
    [self pauseCapturing:nil];
    
    // Change active camera indicator
    self.frontCameraIsActive = !self.frontCameraIsActive;
    
    // Stop session
    [self.captureSession stopRunning];
    [self.captureSession removeInput:self.captureSession.inputs.firstObject];
    
    // Select new capture device
    AVCaptureDevice *newCaptureDevice = self.frontCameraIsActive ? [self frontCamera] : [self backCamera];
    self.currentCaptureDevice = newCaptureDevice;
    
    // Get input stream from the new capture device
    NSError *error;
    AVCaptureDeviceInput *input = [[AVCaptureDeviceInput alloc] initWithDevice:newCaptureDevice error:&error];
    if (error) {
        NSLog(@"Error adding new AVCaptureDeviceInput!");
        [self displayCameraErrorAlert];
        return;
    }
    
    // Set new input for the capture session
    [self.captureSession addInput:input];
    
    // Start capture session
    [self.captureSession startRunning];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ((CaptionsViewController*)segue.destinationViewController).capturedImages = self.capturedImages;
    ((CaptionsViewController*)segue.destinationViewController).delegate = self.delegate;
    ((CaptionsViewController*)segue.destinationViewController).frameSource = GifFrameSourceCamera;
    ((CaptionsViewController*)segue.destinationViewController).creationSource = GifCreationSourceBaked;
}


#pragma mark - Helpers

- (void)displayCameraErrorAlert {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Couldn't get a camera." message:@"Please allow camera usage if you disabled that." preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Open Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController popViewControllerAnimated:true];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
