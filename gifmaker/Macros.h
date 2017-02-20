//
//  Macros.h
//  gifmaker
//
//  Created by Sergii Simakhin on 4/5/16.
//  Copyright © 2016 Cayugasoft. All rights reserved.
//

#ifndef Macros_h
#define Macros_h

#define SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

#define RGB(r,g,b) RGBA(r,g,b,1.0)
#define RGBA(r,g,b,a) ([UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a])

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

#define ANIMATION_MAX_DURATION 5.0
#define GIF_FPS 16.0

#define CAPTIONS_FONT_SIZE 40

#endif /* Macros_h */
