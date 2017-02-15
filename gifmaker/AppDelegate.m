//
//  AppDelegate.m
//  gifmaker
//
//  Created by Sergii Simakhin on 11/12/15.
//  Copyright © 2015 Cayugasoft. All rights reserved.
//

// Frameworks
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKMessengerShareKit/FBSDKMessengerShareKit.h>
#import <AFNetworking/AFNetworking.h>

// Models
#import "AppDelegate.h"

// View Controllers
#import "GifListViewController.h"

@interface AppDelegate ()

@property (nonatomic) BOOL shortcutFromFreshStart;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    if (launchOptions[UIApplicationLaunchOptionsShortcutItemKey]) {
        self.shortcutFromFreshStart = YES;
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    self.shortcutFromFreshStart = NO;
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBSDKAppEvents activateApp];
}

- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler {
    NSString *actionType = [shortcutItem.type componentsSeparatedByString:@"."].lastObject;
    UINavigationController *appNavigationController = ((UINavigationController*)self.window.rootViewController);
    
    if (appNavigationController.presentedViewController != nil) {
        [appNavigationController.presentedViewController dismissViewControllerAnimated:NO completion:^{ }];
    }
    
    [appNavigationController popToRootViewControllerAnimated:NO];
    
    if (![appNavigationController.viewControllers.lastObject isKindOfClass:[GifListViewController class]]) {
        NSLog(@"Navigation tree seems to be corrupted.");
        return;
    }
    
    GifListViewController *gifListVC = appNavigationController.viewControllers.lastObject;
    
    if ([actionType isEqualToString:@"newFromPhotos"]) {
        [gifListVC selectMediaFromGallery:GifFrameSourceGalleryPhotos];
    } else if ([actionType isEqualToString:@"newFromVideo"]) {
        [gifListVC selectMediaFromGallery:GifFrameSourceGalleryVideo];
    } else if ([actionType isEqualToString:@"newFromCamera"]) {
        self.shortcutFromFreshStart ? [gifListVC shootGIFFromCameraNotAnimated:nil] : [gifListVC shootGIFFromCamera:nil];
    }
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

@end
