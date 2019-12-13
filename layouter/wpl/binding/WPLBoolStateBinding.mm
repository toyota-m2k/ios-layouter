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
    id _referenceValue;
    bool _equals;
    bool _compareAsBoolean;
}

- (instancetype) initWithCell:(id<IWPLCell>) cell
                       source:(id<IWPLObservableData>) source
                 customAction:(WPLBindingCustomAction)customAction
                   actionType:(WPLBoolStateActionType) actionType
                     negation:(bool)negation {
    return [self initWithCell:cell
                       source:source
                 customAction:customAction
                   actionType:actionType
               referenceValue:negation ? @false : @true
                       equals:true
             compareAsBoolean:true];
}

- (instancetype)initWithCell:(id<IWPLCell>)cell
                      source:(id<IWPLObservableData>)source
                customAction:(WPLBindingCustomAction)customAction
                  actionType:(WPLBoolStateActionType)actionType
              referenceValue:(id)referenceValue
                      equals:(bool)equals
            compareAsBoolean:(bool) compareAsBoolean {
    self = [super initInternalWithCell:cell
                                source:source
                           bindingMode:WPLBindingModeSOURCE_TO_VIEW
                          customAction:customAction
                  enableSourceListener:false];
    if(nil!=self) {
        _actionType = actionType;
        _referenceValue = referenceValue;
        _equals = equals;
        _compareAsBoolean = compareAsBoolean;
        [self setBoolStateFromSource:source];
        [self startSourceChangeListener];
    }
    return self;
}

- (WPLBoolStateActionType)actionType {
    return _actionType;
}

- (bool) isMatch:(id<IWPLObservableData>)source {
    bool r;
    if(_compareAsBoolean && [_referenceValue isKindOfClass:NSNumber.class]) {
        r = source.boolValue == [(NSNumber*)_referenceValue boolValue];
    } else {
        r = [_referenceValue isEqual:source.value];
    }
    return _equals ? r : !r;
}

- (void) setBoolStateFromSource:(id<IWPLObservableData>) source {
    let v = [self isMatch:source];
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
