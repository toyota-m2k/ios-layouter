//
//  MICUiDsGuardView.m
//
//  Created by @toyota-m2k on 2020/02/04.
//  Copyright (c) 2020 @toyota-m2k. All rights reserved.
//

#import "MICUiDsGuardView.h"
#import "MICTargetSelector.h"
#import "MICUiColorUtil.h"
#import "MICVar.h"

@implementation MICUiDsGuardView {
    MICTargetSelector* _touchAction;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self!=nil){
        self.backgroundColor = MICUiColorARGB(0x20000000);
    }
    return self;
}

+ (instancetype) guardViewOnRootView:(UIView*) rootView
                              target:(id) target
                              action:(SEL) action
                             bgColor:(UIColor*) bgColor {
    let v = [[MICUiDsGuardView alloc] initWithFrame:rootView.bounds];
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
