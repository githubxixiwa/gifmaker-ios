//
//  GifTableViewCell.h
//  gifmaker
//
//  Created by Sergio on 11/27/15.
//  Copyright © 2015 Cayugasoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLAnimatedImageView.h"

@protocol GifTableViewСellActionsDelegate <NSObject>

- (void)shareViaiMessageDidTapHandler:(NSInteger)index;
- (void)deleteMediaDidTapHandler:(NSInteger)index;

@end

@interface GifTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet FLAnimatedImageView *gifView;
@property (strong, nonatomic) IBOutlet UILabel *postedDateLabel;
@property (strong, nonatomic) id delegate;

- (IBAction)shareViaiMessageDidTap:(id)sender;
- (IBAction)deleteButtonDidTap:(id)sender;

@end
