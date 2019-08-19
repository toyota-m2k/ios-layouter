//
//  WPLBoolStateBinding.m
//  WP Layouter
//
//  Created by toyota-m2k on 2019/08/03.
//  Copyright © 2019 toyota-m2k. All rights reserved.
//

#import "WPLBoolStateBinding.h"
#import "MICVar.h"

/**
 * Bool型ソースとViewの状態（visibility, enabled, readonly)のBindingクラス
 */
@implementation WPLBoolStateBinding {
    WPLBoolStateActionType _actionType;
    bool _negation;
}

- (instancetype) initWithCell:(id<IWPLCell>) cell
                       source:(id<IWPLObservableData>) source
                 customAction:(WPLBindingCustomAction)customAction
                   actionType:(WPLBoolStateActionType) actionType
                     negation:(bool)negation {
    self = [super initInternalWithCell:cell source:source bindingMode:(WPLBindingModeSOURCE_TO_VIEW) customAction:customAction enableSourceListener:false];
    if(self!=nil) {
        _actionType = actionType;
        _negation = negation;
        [self setBoolStateFromSource:source];
        [self startSourceChangeListener];
    }
    return self;
}

- (WPLBoolStateActionType)actionType {
    return _actionType;
}

- (bool)negation {
    return _negation;
}

- (void) setBoolStateFromSource:(id<IWPLObservableData>) source {
    let v = (_negation) ? !source.boolValue : source.boolValue;
    switch(_actionType) {
        case WPLBoolStateActionTypeVISIBLE_COLLAPSED:
            self.cell.visibility = v ? WPLVisibilityVISIBLE : WPLVisibilityCOLLAPSED;
            break;
        case WPLBoolStateActionTypeVISIBLE_INVISIBLE:
            self.cell.visibility = v ? WPLVisibilityVISIBLE : WPLVisibilityINVISIBLE;
            break;
        case WPLBoolStateActionTypeENABLED:
            self.cell.enabled = v;
            break;
            
        case WPLBoolStateActionTypeREADONLY:
            if([self.cell conformsToProtocol:@protocol(IWPLCellSuportReadonly)]) {
                ((id<IWPLCellSuportReadonly>)self.cell).readonly = v;
            }
            break;
        default:
            return;
    }
}

- (void) onSourceValueChanged:(id<IWPLObservableData>) source {
    [self setBoolStateFromSource:source];
    [super onSourceValueChanged:source];
}


@end
