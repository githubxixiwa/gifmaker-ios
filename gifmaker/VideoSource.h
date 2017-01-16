//
//  VideoSource.h
//  gifmaker
//
//  Created by Sergii Simakhin on 1/13/17.
//  Copyright © 2017 Cayugasoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface VideoSource : NSObject

@property (nonatomic, strong) UIImage *thumbnail;
@property (nonatomic) NSInteger fps;
@property (nonatomic, strong) AVAsset *asset;

@end
