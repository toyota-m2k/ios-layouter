//
//  WPLObservableMutableData.m
//  WP Layouter
//
//  Created by Mitsuki Toyota on 2019/08/02.
//  Copyright © 2019 Mitsuki Toyota. All rights reserved.
//

#import "WPLObservableMutableData.h"

/**
 * 最も一般的な監視可能オブジェクト
 */
@implementation WPLObservableMutableData

- (void) setValue:(id) v {
    if(v==nil) {
        v = NSNull.null;
    }
    if(![_value isEqual:v]) {
        _value  = v;
        [self valueChanged];
    }
}

- (void) setIntValue:(NSInteger)v {
    [self setValue:[NSNumber numberWithInteger:v]];
}

- (void) setBoolValue:(bool)v {
    [self setValue:[NSNumber numberWithBool:v]];
}

- (void) setFloatValue:(CGFloat) v {
    [self setValue:[NSNumber numberWithFloat:v]];
}

- (void) setStringValue:(NSString*)v {
    [self setValue:v];
}

@end
