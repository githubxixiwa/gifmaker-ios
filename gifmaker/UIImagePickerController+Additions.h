//
//  UIImagePickerController+Additions.h
//  gifmaker
//
//  Created by Sergii Simakhin on 5/10/16.
//  Copyright © 2016 Cayugasoft. All rights reserved.
//

// Frameworks
#import <UIKit/UIKit.h>

@interface UIImagePickerController (Additions)

+ (void)obtainPermissionForMediaSourceType:(UIImagePickerControllerSourceType)sourceType withSuccessHandler:(void (^) ())successHandler andFailure:(void (^) ())failureHandler;

@end
