//
//  GifTableViewCell.m
//  gifmaker
//
//  Created by Sergio on 11/27/15.
//  Copyright © 2015 Cayugasoft. All rights reserved.
//

#import "GifTableViewCell.h"

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

@end
