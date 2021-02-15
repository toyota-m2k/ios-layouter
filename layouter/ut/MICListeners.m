//
//  MICListeners.m
//
//  Created by toyota-m2k on 2019/12/17.
//  Copyright © 2019 toyota-m2k. All rights reserved.
//

#import "MICListeners.h"

@implementation MICListeners {
    NSMutableArray<MICTargetSelector*>* _listeners;
    bool _firing;
}

- (instancetype) init {
    self = [super init];
    if(nil!=self) {
        _listeners = nil;
        _firing = false;
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
    if(_firing) {
        if([key isKindOfClass:MICTargetSelector.class]) {
            ((MICTargetSelector*)key).target = nil;
            return;
        }
    }
    [_listeners removeObject:key];
    if(_listeners.count==0) {
        _listeners = nil;
    }
}

- (void) removeAll {
    [_listeners removeAllObjects];
    _listeners = nil;
}

/**
 * 参照がなくなったリスナーを削除する
 */
- (void) trim {
    if(nil!=_listeners) {
        for(NSInteger i=_listeners.count-1; i>=0; i--) {
            MICTargetSelector* ts = _listeners[i];
            if(ts.target==nil) {
                [_listeners removeObjectAtIndex:i];
            }
        }
        if(_listeners.count==0) {
            _listeners = nil;
        }
    }
}

- (void)fire:(id)param {
    if(nil!=_listeners) {
        _firing = true;
        for(MICTargetSelector* ts in _listeners) {
            [ts performWithParam:&param];
        }
        _firing = false;
        [self trim];
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
