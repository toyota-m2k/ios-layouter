//
//  MICUiVirtualView.m
//  DTable
//
//  Created by 豊田 光樹 on 2014/11/26.
//  Copyright (c) 2014年 豊田 光樹. All rights reserved.
//

#if 0

#import "MICUiVirtualView.h"
#import "MICSpan.h"

@implementation MICUiVirtualView

@synthesize frame = _frame;
@synthesize view = _view;
@synthesize delegate = _delegate;
@synthesize clientData = _clientData;
@synthesize lockCache = _lockCache;


- (CGRect) frame {
    if(nil!=_view) {
        return _view.frame;
    } else {
        return _frame;
    }
}

- (void) setFrame:(CGRect)rect {
    _frame = rect;
    if(nil!=_view) {
        _view.frame = rect;
    }
}

- (bool)isVirtual {
    return _delegate!=nil;
}

- (UIView*) detachCache {
    if(_lockCache) {
        return nil;
    }
    UIView* r = nil;
    if(nil!=_delegate && nil!=_view) {
        _frame = _view.frame;
    }
    return r;
}

- (UIView*) prepareCache:(UIView*)reuseView {
    if(nil!=_delegate && nil==_view) {
        _view = [_delegate realViewForVirtualView:self reuse:reuseView];
        _view.frame = _frame;
    }
    return _view;
}

- (MICUiVirtualView*) initWithRealView:(UIView*)view clientData:(id)anyData{
    self = [super init];
    if(nil!=self) {
        _view = view;
        _delegate = nil;
        _clientData = anyData;
        _lockCache = false;
    }
    return self;
}

- (MICUiVirtualView*) initWithDelegate:(id<MICUiVirtualViewDelegate>)delegate inRect:(CGRect)rect clientData:(id)anyData {
    self = [super init];
    if(nil!=self) {
        _view = nil;
        _frame = rect;
        _delegate = delegate;
        _clientData = anyData;
        _lockCache = false;
    }
    return self;
}


@end

@implementation MICUiVirtualViewCachePool {
    NSMutableArray* _array;
}

@synthesize maxCacheCount = _maxCacheCount;

- (void)setMaxCacheCount:(int)maxCacheCount {
    if(_maxCacheCount!=maxCacheCount) {
        _maxCacheCount = maxCacheCount;
        [self clearPool:-1];
    }
}

- (MICUiVirtualViewCachePool*)init {
    return [self initWithMaxCacheCount:-1];
}

- (MICUiVirtualViewCachePool*)initWithMaxCacheCount:(int)count {
    self = [super init];
    if(nil!=self) {
        _maxCacheCount = count;
        if(count > 0) {
            _array = [[NSMutableArray alloc] initWithCapacity:count];
        } else {
            _array = [[NSMutableArray alloc] init];
        }
    }
    return self;
}

- (void) fetchView:(MICUiVirtualView*)vv {
    UIView* reuse = nil;
    UIView* fetched = nil;
    NSInteger i = _array.count-1;
    if(i>=0) {
        reuse = _array[i];
    }
    fetched = [vv prepareCache:reuse];
    if(nil!=fetched && fetched==reuse) {
        [_array removeObjectAtIndex:i];
    }
}

- (void) releaseView:(MICUiVirtualView*)vv {
    UIView* detached = [vv detachCache];
    if(nil!=detached && ( _maxCacheCount<0 || _array.count<_maxCacheCount)) {
        [_array addObject:detached];
    }
}

- (void) clearPool:(int)maxCount {
    if(maxCount<0) {
        if(_maxCacheCount<0) {
            return;
        }
        maxCount = _maxCacheCount;
    }
    if(_array.count <= maxCount) {
        return;
    }
    [_array removeObjectsInRange:NSMakeRange(maxCount, _array.count - maxCount)];
}

- (void) clearAllPool {
    [_array removeAllObjects];
}


@end

#endif

