//
//  FacebookShareActivity.m
//  gifmaker
//
//  Created by Sergio on 12/23/15.
//  Copyright © 2015 Cayugasoft. All rights reserved.
//

// Frameworks
#import <AFNetworking/AFNetworking.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

// Models
#import "FacebookShareActivity.h"

@implementation FacebookShareActivity

- (NSString *)activityType {
    return @"gifmaker.Share.Facebook";
}

- (NSString *)activityTitle {
    return @"Facebook";
}

- (UIImage *)activityImage {
    return [UIImage imageNamed:@"facebookShare"];
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
    /* First of all we need to upload a GIF to our backend */
    
    // Show progress HUD
    [SVProgressHUD showProgress:0 maskType:SVProgressHUDMaskTypeBlack];
    
    // Create form-data multipart request
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST"
                                                                                              URLString:@"http://gifmaker.cayugasoft.com/index.php?r=api/gifupload"
                                                                                             parameters:nil
                                                                              constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                                                                  [formData appendPartWithFileURL:self.gifURL
                                                                                                             name:@"file"
                                                                                                         fileName:@"file.gif"
                                                                                                         mimeType:@"image/gif"
                                                                                                            error:nil];
                                                                              } error:nil];
    
    // Init session manager
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    // Create upload task
    NSURLSessionUploadTask *uploadTask;
    uploadTask = [manager
                  uploadTaskWithStreamedRequest:request
                  progress:^(NSProgress * _Nonnull uploadProgress) {
                      // Do smth in background thread
                      // ...
                      // Control progress in main thread
                      dispatch_async(dispatch_get_main_queue(), ^{
                          // Update progress bar
                          [SVProgressHUD showProgress:uploadProgress.fractionCompleted maskType:SVProgressHUDMaskTypeBlack];
                      });
                  }
                  completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                      if (error) {
                          NSLog(@"Error: %@", [error localizedDescription]);
                      } else {
                          /* Successfully uploaded. Let's check 'success' status of returned json answer. */
                          BOOL success = responseObject[@"success"];
                          if (success) {
                              NSString *urlString = responseObject[@"data"][@"file"];
                              dispatch_async(dispatch_get_main_queue(), ^{
                                  [SVProgressHUD dismiss];
                                  
                                  FBSDKShareLinkContent *linkContent = [[FBSDKShareLinkContent alloc] init];
                                  linkContent.contentURL = [NSURL URLWithString:urlString];
                                  [FBSDKShareDialog showFromViewController:self.showInViewController withContent:linkContent delegate:nil];
                              });
                          } else {
                              dispatch_async(dispatch_get_main_queue(), ^{
                                  [SVProgressHUD showErrorWithStatus:@"Error on uploading GIF."];
                              });
                          }
                      }
                  }];
    
    // Start upload task. Progress is being informed at the body of this task
    [uploadTask resume];
    
    /* Continue in completion handler ^^^ */
}

@end
