//
//  IMessageShareActivity.m
//  gifmaker
//
//  Created by Sergii Simakhin on 12/23/15.
//  Copyright © 2015 Cayugasoft. All rights reserved.
//

#import "IMessageShareActivity.h"

// Categories
#import "NSObject+Helpers.h"

@implementation IMessageShareActivity

- (NSString *)activityType {
    return @"gifmaker.Share.iMessage";
}

- (NSString *)activityTitle {
    return @"iMessage";
}

- (UIImage *)activityImage {
    return [UIImage imageNamed:@"imessageShare"];
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
    // Check for internet connection
    if (![self checkNetworkIsReachable:self.viewController showAlertIfNoNetwork:YES]) {
        return;
    }
    
    if ([MFMessageComposeViewController canSendText]) {
        MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
        [messageController setMessageComposeDelegate:self.viewController];
        [messageController setRecipients:@[]];
        [messageController setBody:@"Shared with GifMaker!"];
        [messageController addAttachmentData:[NSData dataWithData:self.gifData] typeIdentifier:@"public.movie" filename:@"animation.gif"];
        [self.viewController presentViewController:messageController animated:YES completion:nil];
    } else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:@"Can't share via iMessage!" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self.viewController presentViewController:alertController animated:YES completion:nil];
    }
}

@end
