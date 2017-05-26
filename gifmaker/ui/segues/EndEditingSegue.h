//
//  EndEditingSegue.h
//  gifmaker
//
//  Created by Sergii Simakhin on 4/10/17.
//  Copyright © 2017 Cayugasoft. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, EndEditingGifAnimationType) {
    EndEditingGifAnimationTypeCancel,
    EndEditingGifAnimationTypeBakedGIF
};

/**
 Custom transition called when user press 'Cancel' being on the editing stage to get back to the main screen.
 It can be called to exit the GIF creation process back to the main screen.
 */
@interface EndEditingSegue : UIStoryboardSegue

@property (nonatomic) EndEditingGifAnimationType animationType;

@end
