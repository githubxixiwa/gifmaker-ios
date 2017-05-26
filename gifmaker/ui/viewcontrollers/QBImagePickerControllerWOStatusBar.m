//
//  QBImagePickerControllerWOStatusBar.m
//  gifmaker
//
//  Created by Sergii Simakhin on 5/17/17.
//  Copyright © 2017 Cayugasoft. All rights reserved.
//

#import "QBImagePickerControllerWOStatusBar.h"

@interface QBImagePickerControllerWOStatusBar ()

@end

@implementation QBImagePickerControllerWOStatusBar

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
