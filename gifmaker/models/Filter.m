//
//  Filter.m
//  gifmaker
//
//  Created by Sergii Simakhin on 3/2/17.
//  Copyright © 2017 Cayugasoft. All rights reserved.
//

#define kFilterTitle @"filterTitle"
#define kCIFilterTitle @"CIFilterTitle"
#define kFilterIntensivity @"filterIntensivity"

#define defaultFilterTitle @"Normal"

#import "Filter.h"

@implementation Filter

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = defaultFilterTitle;
        self.ciFilterTitle = @"";
        self.ciFilterIntensivity = 1.0;
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title ciFilterTitle:(NSString *)ciFilterTitle {
    return [self initWithTitle:title ciFilterTitle:ciFilterTitle ciFilterIntensivity:-1];
}

- (instancetype)initWithTitle:(NSString *)title ciFilterTitle:(NSString *)ciFilterTitle ciFilterIntensivity:(CGFloat)filterIntensivity {
    self = [super init];
    if (self) {
        self.title = title;
        self.ciFilterTitle = ciFilterTitle;
        self.ciFilterIntensivity = filterIntensivity;
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.title = [decoder decodeObjectForKey:kFilterTitle];
    self.ciFilterTitle = [decoder decodeObjectForKey:kCIFilterTitle];
    self.ciFilterIntensivity = [[decoder decodeObjectForKey:kFilterIntensivity] floatValue];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.title forKey:kFilterTitle];
    [encoder encodeObject:self.ciFilterTitle forKey:kCIFilterTitle];
    [encoder encodeObject:@(self.ciFilterIntensivity) forKey:kFilterIntensivity];
}


#pragma mark - Helpers

- (BOOL)isNormal {
    return [self.title isEqualToString:defaultFilterTitle];
}

@end
