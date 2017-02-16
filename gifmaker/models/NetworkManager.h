//
//  NetworkManager.h
//  gifmaker
//
//  Created by Sergii Simakhin on 7/14/16.
//  Copyright © 2016 Cayugasoft. All rights reserved.
//

// Frameworks
#import <Foundation/Foundation.h>

@interface NetworkManager : NSObject

+ (instancetype)sharedNetworkManager;
- (void)performAnalyticsActionWithTitle:(NSString *)actionTitle;

@end
