//
//  Exporter.h
//  gifmaker
//
//  Created by Sergio on 12/8/15.
//  Copyright © 2015 Cayugasoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/ALAsset.h>

@interface Exporter : NSObject

/*! Save images array to the videofile in temporary directory. */
+ (void)exportImageArrayAsVideo:(NSArray<UIImage *> *)images
                       filename:(NSString *)filename
                    repeatCount:(NSInteger)repeatCount
                  saveToGallery:(BOOL)saveToGallery;

@end
