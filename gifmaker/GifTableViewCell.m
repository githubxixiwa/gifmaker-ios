//
//  GifTableViewCell.m
//  gifmaker
//
//  Created by Sergio on 11/27/15.
//  Copyright © 2015 Cayugasoft. All rights reserved.
//

#import "GifTableViewCell.h"

@implementation GifTableViewCell

- (IBAction)shareViaiMessageDidTap:(id)sender {
    // Delegate method 'index' is a cell's tag (given by tableView)
    [[self delegate] shareViaiMessageDidTapHandler:self.tag];
}

- (IBAction)deleteButtonDidTap:(id)sender {
    [[self delegate] deleteMediaDidTapHandler:self.tag];
}

- (IBAction)shareViaFBMessengerDidTap:(id)sender {
    [[self delegate] shareViaFBMessengerDidTapHandler:self.tag];
}

- (IBAction)shareToGalleryDidTap:(id)sender {
    [[self delegate] shareToGalleryDidTapHandler:self.tag];
}

@end
