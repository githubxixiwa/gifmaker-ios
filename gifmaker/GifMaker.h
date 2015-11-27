//
//  GifMaker.h
//  gifmaker
//
//  Created by Sergio on 11/24/15.
//  Copyright © 2015 Cayugasoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GifMaker : NSObject

/*! Filename should be without extension */
+ (BOOL)makeAnimatedGif:(NSArray*)frames fps:(NSInteger)fps filename:(NSString*)filename;

@end
