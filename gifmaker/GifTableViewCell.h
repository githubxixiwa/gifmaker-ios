//
//  GifTableViewCell.h
//  gifmaker
//
//  Created by Sergio on 11/27/15.
//  Copyright © 2015 Cayugasoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLAnimatedImageView.h"

@interface GifTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet FLAnimatedImageView *gifView;
@property (strong, nonatomic) IBOutlet UILabel *postedDateLabel;

@end
