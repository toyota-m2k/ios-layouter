//
//  WPLValueBinding.m
//  layouterSample
//
//  Created by Mitsuki Toyota on 2019/08/03.
//  Copyright © 2019 Mitsuki Toyota. All rights reserved.
//

#import "WPLValueBinding.h"
#import "MICVar.h"

/**
 * ValueBinding
 *
 * Viewの値(text/checked, ...) と Sourceの値とをバインドするクラス
 */
@implementation WPLValueBinding {
    id<IWPLCell> _cell;
    id<IWPLObservableData> _source;
    WPLBindingMode _bindingMode;
    WPLBindingCustomAction _customAction;
    id _sourceListenerKey;
    id _cellListenerKey;
}

- (id<IWPLCell>) cell {
    return _cell;
}
- (id<IWPLObservableData>) source {
    return _source;
}
- (WPLBindingMode) bindingMode {
    return _bindingMode;
}
- (WPLBindingCustomAction) customAction {
    return _customAction;
}

- (instancetype) initWithCell:(id<IWPLCell>) cell
                       source:(id<IWPLObservableData>) source
                  bindingMode:(WPLBindingMode)bindingMode
                 customAction:(WPLBindingCustomAction)customAction {
    self = [super init];
    if(self!=nil) {
        _cell = cell;
        _source = source;
        _bindingMode = bindingMode;
        _customAction = customAction;
        _sourceListenerKey = nil;
        _cellListenerKey = nil;
        bool supportValue = [cell conformsToProtocol:@protocol(IWPLCellSupportValue)];
        if(bindingMode != WPLBindingModeVIEW_TO_SOURCE && supportValue) {
            ((id<IWPLCellSupportValue>)cell).value = source.value;
        }
        if(bindingMode==WPLBindingModeTWO_WAY||bindingMode==WPLBindingModeSOURCE_TO_VIEW) {
            _sourceListenerKey = [source addValueChangedListener:self selector:@selector(onSourceValueChanged:)];
        }
        if(bindingMode!=WPLBindingModeSOURCE_TO_VIEW && supportValue) {
            _cellListenerKey = [(id<IWPLCellSupportValue>)cell addInputChangedListener:self selector:@selector(onViewInputChanged:)];
        }
    }
    return self;
}

- (void) dispose {
    _cell = nil;
    _source = nil;
    _customAction = nil;
}

/**
 * ソースの値が変更されたときのハンドラ
 */
- (void) onSourceValueChanged:(id<IWPLObservableData>) source {
    if(self.bindingMode==WPLBindingModeSOURCE_TO_VIEW||self.bindingMode==WPLBindingModeTWO_WAY) {
        let cell = self.cell;
        if([cell conformsToProtocol:@protocol(IWPLCellSupportValue)]) {
            ((id<IWPLCellSupportValue>)cell).value = source.value;
        }
    }
    [self invokeCustomActionFromView:false];
}

/**
 * ビューの値が変更されたときのハンドラ
 */
- (void) onViewInputChanged:(id<IWPLCell>) cell {
    let source = self.source;
    if(self.bindingMode!=WPLBindingModeSOURCE_TO_VIEW && [source conformsToProtocol:@protocol(IWPLObservableMutableData)] && [cell conformsToProtocol:@protocol(IWPLCellSupportValue)]) {
        ((id<IWPLObservableMutableData>)source).value = ((id<IWPLCellSupportValue>)cell).value;
    }
    [self invokeCustomActionFromView:true];
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
