//
//  SaveVideoActivity.m
//  gifmaker
//
//  Created by Sergio on 12/23/15.
//  Copyright © 2015 Cayugasoft. All rights reserved.
//

#import "SaveVideoActivity.h"
#import <SVProgressHUD/SVProgressHUD.h>

@implementation SaveVideoActivity

- (NSString *)activityType {
    return @"gifmaker.Share.SaveVideo";
}

- (NSString *)activityTitle {
    return @"Save to Camera Roll";
}

- (UIImage *)activityImage {
    return [UIImage imageNamed:@"saveVideo"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    
}

- (UIViewController *)activityViewController {
    return nil;
}

- (void)performActivity {
    [SVProgressHUD showWithStatus:@"Exporting... Please wait." maskType:SVProgressHUDMaskTypeBlack];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.gifElement saveToGalleryAsVideo];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    });
}

@end
