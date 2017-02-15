//
//  FacebookMessengerShareActivity.h
//  gifmaker
//
//  Created by Sergii Simakhin on 12/23/15.
//  Copyright © 2015 Cayugasoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBSDKMessengerShareKit/FBSDKMessengerShareKit.h>

@interface FacebookMessengerShareActivity : UIActivity

@property (nonatomic, strong) UIViewController *showInViewController;
@property (nonatomic, strong) NSData *gifData;

@end
