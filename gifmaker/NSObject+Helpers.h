//
//  NSObject+Helpers.h
//  gifmaker
//
//  Created by Sergii Simakhin on 1/4/16.
//  Copyright © 2016 Cayugasoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSObject (Helpers)

/*! Check for network connection and show alert if needed. */
- (BOOL)checkNetworkIsReachable:(UIViewController *)viewController showAlertIfNoNetwork:(BOOL)showAlert;

@end
