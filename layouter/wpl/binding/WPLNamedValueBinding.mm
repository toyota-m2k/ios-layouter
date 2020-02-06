//
//  WPLNamedValueBinding.mm
//
//  Created by @toyota-m2k on 2020/02/03.
//  Copyright @toyota-m2k. All rights reserved.
//

#import "WPLNamedValueBinding.h"
#import "MICVar.h"

/**
 * ValueBinding
 *
 * Viewの値(text/checked, ...) と Sourceの値とをバインドするクラス
 */
@implementation WPLNamedValueBinding {
    id _cellListenerKey;
    NSString* _valueName;
}

- (instancetype) initWithCell:(id<IWPLCellSupportNamedValue>) cell
                    valueName:(NSString*) valueName
                       source:(id<IWPLObservableData>) source
                  bindingMode:(WPLBindingMode)bindingMode
                 customAction:(WPLBindingCustomAction)customAction {
    self = [super initInternalWithCell:cell source:source bindingMode:bindingMode customAction:customAction enableSourceListener:false];
    if(self!=nil) {
        _cellListenerKey = nil;
        _valueName = valueName;
        bool supportValue = [cell conformsToProtocol:@protocol(IWPLCellSupportNamedValue)];
        if(supportValue) {
            if(bindingMode != WPLBindingModeVIEW_TO_SOURCE) {
                [cell setValue:source.value forName:_valueName];
            } else if([source conformsToProtocol:@protocol(IWPLObservableMutableData)]){
                ((id<IWPLObservableMutableData>)source).value = [cell valueForName:_valueName];
            }
        }
        if(bindingMode==WPLBindingModeTWO_WAY||bindingMode==WPLBindingModeSOURCE_TO_VIEW) {
            [self startSourceChangeListener];
        }
        if(bindingMode!=WPLBindingModeSOURCE_TO_VIEW && supportValue) {
            _cellListenerKey = [cell addNamed:_valueName valueListener:self selector:@selector(onValueChanged:ofName:)];
            //[(id<IWPLCellSupportValue>)cell addInputChangedListener:self selector:@selector(onViewInputChanged:)];
        }
    }
    return self;
}

- (void) dispose {
    if(nil!=_cellListenerKey) {
        [(id<IWPLCellSupportNamedValue>)self.cell removeNamed:_valueName valueListener:_cellListenerKey];
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
        if([cell conformsToProtocol:@protocol(IWPLCellSupportNamedValue)]) {
            [(id<IWPLCellSupportNamedValue>)cell setValue:source.value forName:_valueName];
        }
    }
    [self invokeCustomActionFromView:false];
}

/**
 * ビューの値が変更されたときのハンドラ
 */
- (void) onValueChanged:(id<IWPLCell>) cell ofName:(NSString*) name {
    let source = self.source;
    if(self.bindingMode!=WPLBindingModeSOURCE_TO_VIEW && [source conformsToProtocol:@protocol(IWPLObservableMutableData)] && [cell conformsToProtocol:@protocol(IWPLCellSupportNamedValue)]) {
        ((id<IWPLObservableMutableData>)source).value = [(id<IWPLCellSupportNamedValue>)cell valueForName:_valueName];
    }
    [self invokeCustomActionFromView:true];
}


@end
