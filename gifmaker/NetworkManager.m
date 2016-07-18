//
//  NetworkManager.m
//  gifmaker
//
//  Created by Sergio on 7/14/16.
//  Copyright © 2016 Cayugasoft. All rights reserved.
//

#import "NetworkManager.h"

@implementation NetworkManager

+ (instancetype)sharedNetworkManager
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once (&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

#pragma mark - Static instances

static NSString * const APIDomain = @"http://telemetry.ego-cms.com/save";

- (NSString *) APPToSave {
    #ifdef DEBUG
        return @"gifmaker-debug";
    #else
        return @"gifmaker-production";
    #endif
}


#pragma mark - Shared NetworkManager Methods

- (void)performAnalyticsActionWithTitle:(NSString *)actionTitle {
    [self makeNetworkRequest:[self urlStringFromActionTitle:actionTitle]];
}

#pragma mark - Private Methods

- (NSString *)urlStringFromActionTitle:(NSString *)actionTitle {
    return [NSString stringWithFormat:@"%@/%@/%@", APIDomain, [self APPToSave], actionTitle];
}

- (void)makeNetworkRequest:(NSString *)urlString {
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    urlRequest.HTTPMethod = @"GET";
    urlRequest.timeoutInterval = 10.0;
    
    NSURLSessionDataTask *urlSessionTask = [[NSURLSession sharedSession] dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // Check for response error
        if (error != nil) {
            NSLog(@"Analytics:: error sending request %@: %@", urlString, [error localizedDescription]);
        }
        
        // Check for response availablity
        if (response != nil) {
            // Check for response status code
            if (((NSHTTPURLResponse *)response).statusCode == 200) {
                // Get response json dictionary
                NSError *jsonReaderError;
                NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonReaderError];
                if (jsonReaderError == nil) {
                    // Get response json dictionary status
                    NSString *status = jsonDictionary[@"status"];
                    
                    if ([status isEqualToString:@"accepted"]) {
                        NSLog(@"Analytics:: sent successfully.");
                    } else {
                        NSLog(@"Analytics:: got wrong status code '%@' on %@: %@", status, urlString, [error localizedDescription]);
                    }
                } else {
                    NSLog(@"Analytics:: error parsing json %@: %@", urlString, [error localizedDescription]);
                }
            }
        } else {
            NSLog(@"Analytics:: error reading response %@: %@", urlString, [error localizedDescription]);
        }
        
    }];
    [urlSessionTask resume];
}

@end
