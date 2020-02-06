//
//  WPLPropBinding.m
//
//  Created by toyota-m2k on 2019/08/26.
//  Copyright © 2019 toyota-m2k. All rights reserved.
//

#import "WPLPropBinding.h"
#import "MICDicUtil.h"
#import "MICVar.h"

@implementation WPLPropBinding {
}

- (instancetype)initWithCell:(id<IWPLCell>)cell
                      source:(id<IWPLObservableData>)source
                    propType:(WPLPropType)propType
                customAction:(WPLBindingCustomAction)customAction {
    self = [super initInternalWithCell:cell source:source
                           bindingMode:(WPLBindingModeSOURCE_TO_VIEW)
                          customAction:customAction
                  enableSourceListener:false];
    if(self!=nil) {
        _propType = propType;
        [self setPropFromSource:source];
        [self startSourceChangeListener];
    }
    return self;
}

- (void) setPropFromSource:(id<IWPLObservableData>) source {
    switch(_propType) {
        case WPLPropTypeALPHA:
            self.cell.view.alpha = source.floatValue;
            break;
        case WPLPropTypeBG_COLOR:
            if([source.value isKindOfClass:UIColor.class]) {
                self.cell.view.backgroundColor = source.value;
            }
            break;
        case WPLPropTypeFG_COLOR:
            if([source.value isKindOfClass:UIColor.class] &&
               [self.cell.view respondsToSelector:@selector(setTextColor:)]) {
                [(id)self.cell.view setTextColor:(source.value)];
            }
            break;
        case WPLPropTypeTEXT:
            if([self.cell.view respondsToSelector:@selector(setText:)]) {
                [(id)self.cell.view setText:source.stringValue];
            } else if ([self.cell.view respondsToSelector:@selector(setTitle:forState:)]) {
                [(id)self.cell.view setTitle:source.stringValue forState:UIControlStateNormal];
            }
            break;
        case WPLPropTypePLACEHOLDER:
            if([self.cell.view respondsToSelector:@selector(setPlaceholder:)]) {
                [(id)self.cell.view setPlaceholder:source.stringValue];
            }
            break;
        case WPLPropTypeSELECTED:
            if([self.cell.view respondsToSelector:@selector(setSelected:)]) {
                [(id)self.cell.view setSelected:source.boolValue];
            }
            break;
        default:
            break;
    }
}

/**
 * ソースが変更されたときのイベントハンドラ
 */
- (void) onSourceValueChanged:(id<IWPLObservableData>) source {
    [self setPropFromSource:source];
    [super onSourceValueChanged:source];
}

@end
