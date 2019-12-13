//
//  WPLSubject.m
//
//  Created by toyota-m2k on 2019/12/11.
//  Copyright © 2019 toyota-m2k. All rights reserved.
//

#import "WPLSubject.h"

/**
 * valueプロパティのセッターで、値が変化していなくても、valueChangedを発行する点を除いて、
 * WPLObservableMutableData と同じ。
 * 他のObservableたちと同じ流儀で、event を扱えるようにしたかった。
 */
@implementation WPLSubject

- (void)setValue:(id)value {
    if(![self.value isEqual:value]) {
        [super setValue:value];
    } else {
        [self valueChanged];
    }
}

- (void) trigger {
    [self valueChanged];
}

- (void) trigger:(id)value {
    [self setValue:value];
}

@end
