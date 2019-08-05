//
//  WPLBindingBase.m
//  layouterSample
//
//  Created by Mitsuki Toyota on 2019/08/05.
//  Copyright © 2019 Mitsuki Toyota. All rights reserved.
//

#import "WPLBindingBase.h"
#import "WPLCellDef.h"
#import "WPLObservableDef.h"

@implementation WPLBindingBase

@synthesize source=_source, cell=_cell, bindingMode=_bindingMode, customAction = _customAction;

- (instancetype)init {
    NSAssert(false, @"don't use default constructor.");
    return nil;
}

- (instancetype) initWithCell:(id<IWPLCell>)cell
                       source:(id<IWPLObservableData>)source
                  bindingMode:(WPLBindingMode)bindingMode
                 customAction:(WPLBindingCustomAction) customAction {
    self = [super init];
    if(nil!=self) {
        _cell = cell;
        _source = source;
        _bindingMode = bindingMode;
        _customAction = customAction;
    }
    return self;
}



- (void)dispose {
    _cell = nil;
    _source = nil;
    _customAction = nil;
}

/**
 * カスタムアクションを呼び出す
 */
- (void) invokeCustomActionFromView:(bool) fromView {
    if(nil!=_customAction) {
        _customAction(self, fromView);
    }
}

@end
