//
//  SaveVideoActivity.m
//  gifmaker
//
//  Created by Sergio on 12/23/15.
//  Copyright © 2015 Cayugasoft. All rights reserved.
//

#import "SaveVideoActivity.h"

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
    [self.gifElement saveToGalleryAsVideo];
}

@end
