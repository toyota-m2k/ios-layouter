//
//  WPLObserver.m
//
//  Created by toyota-m2k on 2020/04/14.
//  Copyright © 2020 toyota-m2k. All rights reserved.
//

#import "WPLObserver.h"


@implementation WPLObserver {
    void (^_callback)(id<IWPLObservableData> _Nonnull);
    id _key;
}

- (instancetype)initWithSource:(id<IWPLObservableData>)source onNext:(void (^)(id<IWPLObservableData> _Nonnull))callback {
    self = [super init];
    if(nil!=self) {
        _source = source;
        _callback = callback;
        _key = [source addValueChangedListener:self selector:@selector(onNext:)];
    }
    return self;
}

- (void) onNext:(id) sender {
    _callback(sender);
}

- (void) dispose {
    if(nil!=_source && nil!=_key) {
        [_source removeValueChangedListener:_key];
    }
    _callback = nil;
    _source = nil;
    _key = nil;
}

+ (instancetype)asObserver:(id<IWPLObservableData>)source onNext:(void (^)(id<IWPLObservableData> _Nonnull))callback {
    return [[self.class alloc] initWithSource:source onNext:callback];
}

@end
