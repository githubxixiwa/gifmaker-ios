//
//  FacebookShareActivity.h
//  gifmaker
//
//  Created by Sergio on 12/23/15.
//  Copyright © 2015 Cayugasoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FacebookShareActivity : UIActivity

@property (nonatomic, strong) UIViewController *showInViewController;
@property (nonatomic, strong) NSURL *gifURL;

@end
