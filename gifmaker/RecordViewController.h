//
//  RecordViewController.h
//  gifmaker
//
//  Created by Sergii Simakhin on 11/24/15.
//  Copyright © 2015 Cayugasoft. All rights reserved.
//

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
@property (weak, nonatomic) IBOutlet UIView *cardView;

@property (nonatomic, strong) id delegate;

- (IBAction)changeCameraButtonDidTap:(id)sender;

@end
