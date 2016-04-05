//
//  Macros.h
//  gifmaker
//
//  Created by Sergio on 4/5/16.
//  Copyright © 2016 Cayugasoft. All rights reserved.
//

#ifndef Macros_h
#define Macros_h

#define RGB(r,g,b) RGBA(r,g,b,1.0)
#define RGBA(r,g,b,a) ([UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a])

#endif /* Macros_h */
