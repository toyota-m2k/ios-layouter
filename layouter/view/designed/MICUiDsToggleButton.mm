//
//  MICUiDsToggleButton.m
//  ボタンタップで選択状態がトグルするボタン
//
//  Created by toyota.m2k on 2020/10/15.
//  Copyright © 2020 toyota.m2k Corporation. All rights reserved.
//

#import "MICUiDsToggleButton.h"
#import "MICVar.h"
#import "MICListeners.h"

@implementation MICUiDsToggleButton {
    MICTargetSelector* _actionOnSelected;
}

#pragma mark - Overrides
/**
 * MICUiDsCustomButton.customButtonDelegate をオーバーライド
 * このデリゲートは、トグルボタンのアクション専用となり、外部からの設定は受け付けない。
 * ToggleButtonへのタップイベントのハンドリングが必要なら、setTarget:action メソッドを使うこと。
 */
- (id<MICUiDsCustomButtonDelegate>)customButtonDelegate {
    return self;
}
- (void)setCustomButtonDelegate:(id<MICUiDsCustomButtonDelegate>)customButtonDelegate {
    NSAssert(false, @"cannot set customButtonDelegate to MICUiDsToggleButton");
}

#pragma mark - Properties & Events

/**
 * チェックボタンの状態が変化したときのイベント
 * @param action    (void)onChanged:(MICUiDsToggleButton*)sender
 */
- (void)setSelectedListener:(id)target action:(SEL)action {
    if(target!=nil && action!=nil) {
        _actionOnSelected = [[MICTargetSelector alloc] initWithTarget:target selector:action];
    } else {
        _actionOnSelected = nil;
    }
}

#pragma mark - MICUiDsCustomButtonDelegate i/f

/**
 * ボタンの状態(buttonStateプロパティ)が変更されたときの通知
 */
- (void) onCustomButtonStateChangedAt:(MICUiDsCustomButton*)view from:(MICUiViewState)before to:(MICUiViewState)after {
    
}

/**
 * ボタンがタップされたときの通知
 */
- (void) onCustomButtonTapped:(MICUiDsCustomButton*)view {
    // トグル
    self.selected = !self.selected;
    if(nil!=_actionOnSelected) {
        id me = self;
        [_actionOnSelected performWithParam:&me];
    }
}

@end

#pragma mark - IWPLCell Supports

@implementation MICUiDsToggleButtonCell {
    MICListeners* _commandListeners;
}

- (instancetype) initWithView:(UIView*)view
                         name:(NSString*) name
                       margin:(UIEdgeInsets) margin
              requestViewSize:(CGSize) requestViewSize
                   limitWidth:(WPLMinMax) limitWidth
                  limitHeight:(WPLMinMax) limitHeight
                   hAlignment:(WPLCellAlignment)hAlignment
                   vAlignment:(WPLCellAlignment)vAlignment
                   visibility:(WPLVisibility)visibility {
    NSAssert([view isKindOfClass:MICUiDsToggleButton.class], @"MICUiDsToggleButton: view must be instance of MICUiDsToggleButton");
    self = [super initWithView:view
                          name:name
                        margin:margin
               requestViewSize:requestViewSize
                    limitWidth:limitWidth
                   limitHeight:limitHeight
                    hAlignment:hAlignment
                    vAlignment:vAlignment
                    visibility:visibility];
    if(nil!=self) {
        _commandListeners = nil;
        [(MICUiDsToggleButton*)view setSelectedListener:self action:@selector(onSelectionChanged:)];
    }
    return self;
}

- (void)dispose {
    [(MICUiDsToggleButton*)self.view setSelectedListener:nil action:nil];
    if(_commandListeners!=nil) {
        [_commandListeners removeAll];
        _commandListeners = nil;
    }
}

- (id) value {
    return @(((MICUiDsToggleButton*)self.view).selected);
}

- (void) setValue:(id)v {
    bool bv = ([v isKindOfClass:NSNumber.class]) ? ((NSNumber*)v).boolValue : false;
    if(!(((MICUiDsToggleButton*)self.view).selected)!=!bv) {
        ((MICUiDsToggleButton*)self.view).selected = bv;
    }
}

- (void) onSelectionChanged:(id) _ {
    if(nil!=_commandListeners) {
        [_commandListeners fire:self];
    }
    [self onValueChanged];
}

- (id)addCommandListener:(id)target selector:(SEL)selector {
    if(nil==_commandListeners) {
        _commandListeners = MICListeners.listeners;
    }
    return [_commandListeners addListener:target action:selector];
}

- (void)removeCommandListener:(id)key {
    if(nil!=_commandListeners) {
    [_commandListeners removeListener:key];
        if(_commandListeners.isEmpty) {
            _commandListeners = nil;
        }
    }
}

@end
