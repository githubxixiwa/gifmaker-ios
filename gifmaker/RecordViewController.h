//
//  RecordViewController.h
//  gifmaker
//
//  Created by Sergio on 11/24/15.
//  Copyright © 2015 Cayugasoft. All rights reserved.
//

#define VIDEO_DURATION 5.0
#define GIF_FPS 16.0
#define GIF_SIDE_SIZE 480

// Frameworks
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

// Models
#import "LLACircularProgressView.h"

@protocol RecordGifDelegate <NSObject>
- (void)refresh;
@end

@interface RecordViewController : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate>

@property (weak, nonatomic) IBOutlet UIView *cameraPreviewUIView;
@property (weak, nonatomic) IBOutlet LLACircularProgressView *circularProgressView;

@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

@property (nonatomic, strong) id delegate;

- (IBAction)changeCameraButtonDidTap:(id)sender;

@end
