//
//  GifTableViewCell.m
//  gifmaker
//
//  Created by Sergii Simakhin on 11/27/15.
//  Copyright © 2015 Cayugasoft. All rights reserved.
//

#import "Macros.h"

// Models
#import "GifManager.h"
#import "GifTableViewCell.h"

@interface GifTableViewCell()

@property (nonatomic) BOOL rotated;

@end

@implementation GifTableViewCell

- (IBAction)shareButtonDidTap:(id)sender {
    [[self delegate] shareButtonDidTapHandler:self.tag];
}

- (IBAction)editGifDidTap:(id)sender {
    [[self delegate] editButtonDidTapHandler:self.tag];
}

- (IBAction)deleteButtonDidTap:(id)sender {
    // Delegate method 'index' is a cell's tag (given by tableView)
    [[self delegate] deleteMediaDidTapHandler:self.tag];
}

- (void)drawRect:(CGRect)rect {
    [self.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [self.layer setShadowOffset:CGSizeMake(6, 6)];
    [self.layer setShadowRadius:3.0];
    [self.layer setShadowOpacity:0.3];
    
    [self.gifView.layer setBorderColor:[UIColor blackColor].CGColor];
    [self.gifView.layer setBorderWidth:1.0f];
    [self.gifView.layer setShouldRasterize:YES];
    
    [self.cardView.layer setAllowsEdgeAntialiasing:YES];
    [self.gifView.layer  setAllowsEdgeAntialiasing:YES];
    
    if (!self.rotated) {
        NSArray *degrees = @[@(356), @(0), @(357), @(0), @(358), @(359), @(360), @(0), @(1), @(0), @(2), @(0), @(3), @(0), @(4)];
        NSInteger randomDegree = [degrees[arc4random_uniform((u_int32_t)[degrees count])] integerValue];
        double rads = DEGREES_TO_RADIANS(randomDegree);
        CGAffineTransform transform = CGAffineTransformRotate(CGAffineTransformIdentity, rads);
        self.cardView.transform = transform;
        self.rotated = YES;
    }
}

@end
