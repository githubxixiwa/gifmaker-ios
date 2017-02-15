//
//  NSString+Extras.m
//  gifmaker
//
//  Created by Sergii Simakhin on 11/27/15.
//  Copyright © 2015 Cayugasoft. All rights reserved.
//

#import "NSString+Extras.h"

@implementation NSString (Extras)

+ (NSString *) generateRandomString {
    int len = 50;
    static NSString * letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString * randomString = [NSMutableString stringWithCapacity: len];
    for (int i = 0; i < len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
    }
    
    return randomString;
}

@end
