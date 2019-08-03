//
//  WPLBoolStateBinding.m
//  layouterSample
//
//  Created by Mitsuki Toyota on 2019/08/03.
//  Copyright © 2019 Mitsuki Toyota. All rights reserved.
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
                  bindingMode:(WPLBindingMode)bindingMode customAction:(WPLBindingCustomAction)customAction
                   actionType:(WPLBoolStateActionType) actionType
                     negation:(bool)negation {
    self = [super initWithCell:cell source:source bindingMode:bindingMode customAction:customAction];
    if(self!=nil) {
        _actionType = actionType;
        _negation = negation;
    }
    return self;
}

- (WPLBoolStateActionType)actionType {
    return _actionType;
}

- (bool)negation {
    return _negation;
}

- (void) onSourceValueChanged:(id<IWPLObservableData>) source {
    if(self.bindingMode!=WPLBindingModeSOURCE_TO_VIEW && self.bindingMode!=WPLBindingModeTWO_WAY) {
        return;
    }
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
    [self invokeCustomActionFromView:false];
}

- (void) onViewInputChanged:(id<IWPLCell>) cell {
    // ignored
}

@end
