//
//  GifTableViewCell.h
//  gifmaker
//
//  Created by Sergii Simakhin on 11/27/15.
//  Copyright © 2015 Cayugasoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLAnimatedImageView.h"

@protocol GifTableViewСellActionsDelegate <NSObject>

- (void)shareButtonDidTapHandler:(NSInteger)index;
- (void)editButtonDidTapHandler:(NSInteger)index;
- (void)deleteMediaDidTapHandler:(NSInteger)index;

@end

@interface GifTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *cardView;
@property (weak, nonatomic) IBOutlet FLAnimatedImageView *gifView;
@property (weak, nonatomic) IBOutlet UILabel *postedDateLabel;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) id delegate;

- (IBAction)shareButtonDidTap:(id)sender;
- (IBAction)editGifDidTap:(id)sender;
- (IBAction)deleteButtonDidTap:(id)sender;

@end
