//
//  SaveVideoActivity.m
//  gifmaker
//
//  Created by Sergii Simakhin on 12/23/15.
//  Copyright © 2015 Cayugasoft. All rights reserved.
//

// Models
#import "SaveVideoActivity.h"
#import "AnalyticsManager.h"

// Frameworks
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
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD showWithStatus:@"Exporting... Please wait."];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.gifElement saveToGalleryAsVideo];
        [[AnalyticsManager sharedAnalyticsManager] gifSharedViaSavingLocallyAsVideo];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    });
}

@end
