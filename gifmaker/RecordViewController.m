//
//  RecordViewController.m
//  gifmaker
//
//  Created by Sergio on 11/24/15.
//  Copyright © 2015 Cayugasoft. All rights reserved.
//

// View Controllers
#import "RecordViewController.h"
#import "CaptionsViewController.h"

// Models
#import "GifManager.h"

// Categories
#import "UIImage+Extras.h"
#import "NSString+Extras.h"

@interface RecordViewController ()

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureDevice *currentCaptureDevice;
@property (nonatomic, strong) NSMutableArray<UIImage *> *capturedImages;
@property (nonatomic) BOOL recording;
@property (nonatomic) BOOL frontCameraIsActive;

@end

@implementation RecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.capturedImages = [NSMutableArray array];
    self.recording = NO;
    self.frontCameraIsActive = YES;
    
    [self.circularProgressView addTarget:self action:@selector(capture:) forControlEvents:UIControlEventTouchDown];
    [self.circularProgressView addTarget:self action:@selector(pauseCapturing:) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.title = @"Shoot YOUR gif!";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleDone target:self action:@selector(nextButtonDidTap:)];
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Init capture session
    self.captureSession = [[AVCaptureSession alloc] init];
    
    AVCaptureDevice *device = [self frontCamera];
    
    if (!device) {
        NSLog(@"Couldn't get a camera.");
        return;
    }
    
    NSError *error;
    AVCaptureDeviceInput *input = [[AVCaptureDeviceInput alloc] initWithDevice:device
                                                                         error:&error];
    if (error) {
        NSLog(@"Error adding new AVCaptureDeviceInput!");
    }
    
    if (input) {
        [self.captureSession addInput:input];
    } else {
        NSLog(@"Couldn't initialize device input: %@", error);
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
        if (self.capturedImages.count == GIF_FPS * VIDEO_DURATION && self.circularProgressView.enabled == YES) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.circularProgressView setAlpha:0.3];
                [self.instructionsLabel setText:@"You've run out of time!\nNow press \"Next\""];
            });
        }
        return;
    } else {
        CGFloat progress = self.capturedImages.count / ((GIF_FPS * VIDEO_DURATION) - 1);
        //NSLog(@"Setting progress %f", progress);
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
    UIImage *croppedImage = [UIImage imageByCroppingCGImage:videoImage toSize:CGSizeMake(GIF_SIDE_SIZE, GIF_SIDE_SIZE)];
    
    // Add captured frame to 'capturedImages' array
    [self.capturedImages addObject:croppedImage];
    
    // Clean memory
    CGImageRelease(videoImage);
}


#pragma mark - Camera position

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

- (void)nextButtonDidTap:(id)sender {
    [self.captureSession stopRunning];
    [self performSegueWithIdentifier:@"toCaptionsSegue" sender:self];
}

- (void)capture:(id)sender {
    self.recording = YES;
    NSLog(@"Capturing");
}

- (void)pauseCapturing:(id)sender {
    self.recording = NO;
    NSLog(@"Paused. Captured %lu frames", (unsigned long)self.capturedImages.count);
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
}

@end
