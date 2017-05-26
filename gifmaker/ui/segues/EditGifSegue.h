//
//  EditGifSegue.h
//  gifmaker
//
//  Created by Sergii Simakhin on 4/4/17.
//  Copyright © 2017 Cayugasoft. All rights reserved.
//

#define GifCardXTransformConstant 0.034
#define GifCardYTransformConstant 0.04

// Frameworks
#import <UIKit/UIKit.h>

// Views
#import "GifTableViewCell.h"

/**
 Custom transition called when user press 'Edit' on the GIF card to display an editor
 */
@interface EditGifSegue : UIStoryboardSegue

@property (nonatomic, strong) GifTableViewCell *previousGifCell;
@property (nonatomic, strong) GifTableViewCell *editingGifCell;
@property (nonatomic, strong) GifTableViewCell *nextGifCell;

@end
