//
//  FacebookShareActivity.h
//  gifmaker
//
//  Created by Sergii Simakhin on 12/23/15.
//  Copyright © 2015 Cayugasoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

@interface FacebookShareActivity : UIActivity <FBSDKSharingDelegate>

@property (nonatomic, strong) UIViewController *showInViewController;
@property (nonatomic, strong) NSURL *gifURL;

@end
