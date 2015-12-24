//
//  FacebookMessengerShareActivity.m
//  gifmaker
//
//  Created by Sergio on 12/23/15.
//  Copyright © 2015 Cayugasoft. All rights reserved.
//

#import "FacebookMessengerShareActivity.h"

@implementation FacebookMessengerShareActivity

- (NSString *)activityType {
    return @"gifmaker.Share.FacebookMessenger";
}

- (NSString *)activityTitle {
    return @"Facebook Messenger";
}

- (UIImage *)activityImage {
    return [UIImage imageNamed:@"facebookMessengerShare"];
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
    [FBSDKMessengerSharer shareAnimatedGIF:self.gifData withOptions:nil];
}


@end
