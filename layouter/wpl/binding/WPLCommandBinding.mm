//
//  WPLCommandBinding.m
//  ボタンなどのタップイベントをValueChangedイベントとして発行するバインディングクラス
//
//  Created by toyota-m2k on 2019/12/17.
//  Copyright © 2019 toyota-m2k. All rights reserved.
//

#import "WPLCommandBinding.h"
#import "WPLCellDef.h"
#import "WPLObservableDef.h"

@implementation WPLCommandBinding

- (instancetype)initWithCell:(id<IWPLCell>)cell source:(id<IWPLObservableData>)source customAction:(WPLBindingCustomAction)customAction {
    self = [super initInternalWithCell:cell source:source
                           bindingMode:(WPLBindingModeVIEW_TO_SOURCE)
                          customAction:customAction
                  enableSourceListener:false];
    if(self!=nil) {
        if([cell conformsToProtocol:@protocol(IWPLCellSupportCommand)]) {
            [(id<IWPLCellSupportCommand>)cell addCommandListener:self selector:@selector(onTapped:)];
        }
    }
    return self;

}

- (void) onTapped:(id)sender {
    if([self.source conformsToProtocol:@protocol(IWPLObservableMutableData)]) {
        ((id<IWPLObservableMutableData>)self.source).value = sender;
    }
    [super onSourceValueChanged:self.source];
}

@end
