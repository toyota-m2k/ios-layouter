//
//  MICListeners.m
//
//  Created by toyota-m2k on 2019/12/17.
//  Copyright © 2019 toyota-m2k. All rights reserved.
//

#import "MICListeners.h"

@implementation MICListeners {
    NSMutableArray<MICTargetSelector*>* _listeners;
}

- (instancetype) init {
    self = [super init];
    if(nil!=self) {
        _listeners = nil;
    }
    return self;
}

+ (instancetype) listeners {
    return [self new];
}

- (id) addListener:(id)target action:(SEL)action {
    return [self addListener:[MICTargetSelector targetSelector:target selector:action]];
}

- (id) addListener:(MICTargetSelector*)listener {
    if(nil==_listeners) {
        _listeners = NSMutableArray.array;
    }
    [_listeners addObject:listener];
    return listener;
}

- (void) removeListener:(id)key {
    [_listeners removeObject:key];
    if(_listeners.count==0) {
        _listeners = nil;
    }
}

- (void) removeAll {
    [_listeners removeAllObjects];
    _listeners = nil;
}

- (void)fire:(id)param {
    if(nil!=_listeners) {
        for(MICTargetSelector* ts in _listeners) {
            [ts performWithParam:&param];
        }
    }
}

- (void) forEach:(void (^)(MICTargetSelector*))cb {
    if(nil!=_listeners) {
        for(MICTargetSelector* ts in _listeners) {
            cb(ts);
        }
    }
}

- (bool) isEmpty {
    return nil==_listeners || _listeners.count==0;
}


@end
