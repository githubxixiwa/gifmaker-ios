//
//  GifFilterCollectionViewCell.h
//  gifmaker
//
//  Created by Sergii Simakhin on 2/28/17.
//  Copyright © 2017 Cayugasoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

@interface GifFilterCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *previewImage;
@property (weak, nonatomic) IBOutlet UILabel *title;

@end
