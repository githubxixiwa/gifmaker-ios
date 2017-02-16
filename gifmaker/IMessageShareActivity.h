//
//  IMessageShareActivity.h
//  gifmaker
//
//  Created by Sergii Simakhin on 12/23/15.
//  Copyright © 2015 Cayugasoft. All rights reserved.
//

// Frameworks
#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface IMessageShareActivity : UIActivity

@property (nonatomic, strong) NSData *gifData;
@property (nonatomic, strong) UIViewController<MFMessageComposeViewControllerDelegate> *viewController;

@end
