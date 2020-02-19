//
//  MICUiDsGuardView.m
//
//  Created by @toyota-m2k on 2020/02/04.
//  Copyright (c) 2020 @toyota-m2k. All rights reserved.
//

#import "MICUiDsGuardView.h"
#import "MICTargetSelector.h"
#import "MICKeyValueObserver.h"
#import "MICUiColorUtil.h"
#import "MICVar.h"

@implementation MICUiDsGuardView {
    MICTargetSelector* _touchAction;
    MICKeyValueObserver* _observer;
    __weak UIView* _rootView;
}

- (instancetype)initWithRootView:(UIView*)rootView {
    self = [super initWithFrame:rootView.bounds];
    if(self!=nil){
        _rootView = rootView;
        self.backgroundColor = MICUiColorARGB(0x20000000);
    }
    return self;
}

/**
 * rootViewのサイズ変更に追従
 */
- (void) sizePropertyChanged:(id<IMICKeyValueObserverItem>) info target:(id)target {
    self.frame = ((UIView*)target).frame;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if(nil!=newSuperview) {
        if(nil!=_rootView && nil==_observer) {
            _observer = [[MICKeyValueObserver alloc] initWithActor:_rootView];
            [_observer add:@"frame" listener:self handler:@selector(sizePropertyChanged:target:)];
            [_observer add:@"bounds" listener:self handler:@selector(sizePropertyChanged:target:)];
        }
    } else {
        if(nil!=_observer) {
            [_observer dispose];
            _observer = nil;
        }
    }
}

+ (instancetype) guardViewOnRootView:(UIView*) rootView
                              target:(id) target
                              action:(SEL) action
                             bgColor:(UIColor*) bgColor {
    let v = [[MICUiDsGuardView alloc] initWithRootView:rootView];
    if(bgColor!=nil) {
        v.backgroundColor = bgColor;
    }
    [v setTouchListener:target action:action];
    v.hidden = false;
    [rootView addSubview:v];
    return v;
}

+ (instancetype) guardViewOnRootView:(UIView*) rootView
                              target:(id) target
                              action:(SEL) action {
    return [self guardViewOnRootView:rootView target:target action:action bgColor:nil];
}


- (void) setTouchListener:(id) target action:(SEL) action {
    _touchAction = [MICTargetSelector target:target selector:action];
}

- (void) show {
    self.hidden = false;
}

- (void) hide {
    self.hidden = true;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if(_touchAction!=nil) {
        [_touchAction perform];
    }
}

@end
