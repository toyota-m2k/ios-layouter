//
//  WPLValueBinding.m
//  WP Layouter
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
    id _cellListenerKey;
}

- (instancetype) initWithCell:(id<IWPLCell>) cell
                       source:(id<IWPLObservableData>) source
                  bindingMode:(WPLBindingMode)bindingMode
                 customAction:(WPLBindingCustomAction)customAction {
    self = [super initInternalWithCell:cell source:source bindingMode:bindingMode customAction:customAction enableSourceListener:false];
    if(self!=nil) {
        _cellListenerKey = nil;
        bool supportValue = [cell conformsToProtocol:@protocol(IWPLCellSupportValue)];
        if(supportValue) {
            if(bindingMode != WPLBindingModeVIEW_TO_SOURCE) {
                ((id<IWPLCellSupportValue>)cell).value = source.value;
            } else if([source conformsToProtocol:@protocol(IWPLObservableMutableData)]){
                ((id<IWPLObservableMutableData>)source).value = ((id<IWPLCellSupportValue>)cell).value;
            }
        }
        if(bindingMode==WPLBindingModeTWO_WAY||bindingMode==WPLBindingModeSOURCE_TO_VIEW) {
            [self startSourceChangeListener];
        }
        if(bindingMode!=WPLBindingModeSOURCE_TO_VIEW && supportValue) {
            _cellListenerKey = [(id<IWPLCellSupportValue>)cell addInputChangedListener:self selector:@selector(onViewInputChanged:)];
        }
    }
    return self;
}

- (void) dispose {
    if(nil!=_cellListenerKey) {
        [(id<IWPLCellSupportValue>)self.cell removeInputListener:_cellListenerKey];
        _cellListenerKey = nil;
    }
    [super dispose];
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


@end
