//
//  WPLCommandCell.m
//  UIButton を内包して、tappedイベントを発行するセル
//
//  Created by toyota-m2k on 2019/12/17.
//  Copyright © 2019 toyota-m2k. All rights reserved.
//


#import "WPLCommandCell.h"
#import "MICListeners.h"
#import "MICVar.h"
#import "MICUiDsCustomButton.h"

@implementation WPLCommandCell {
    MICListeners* _commandListeners;
}

#pragma mark - 初期化・解放

- (instancetype) initWithView:(UIView*)view
                         name:(NSString*) name
                       margin:(UIEdgeInsets) margin
              requestViewSize:(CGSize) requestViewSize
                   limitWidth:(WPLMinMax) limitWidth
                  limitHeight:(WPLMinMax) limitHeight
                   hAlignment:(WPLCellAlignment)hAlignment
                   vAlignment:(WPLCellAlignment)vAlignment
                   visibility:(WPLVisibility)visibility {
    self = [super initWithView:view
                          name:name
                        margin:margin
               requestViewSize:requestViewSize
                    limitWidth:limitWidth
                   limitHeight:limitHeight
                    hAlignment:hAlignment
                    vAlignment:vAlignment
                    visibility:visibility];
    if(self!=nil) {
        _commandListeners = nil;
    }
    return self;
}

- (void) dispose {
    if(nil!=_commandListeners) {
        [_commandListeners removeAll];
        _commandListeners = nil;
    }
}

#pragma mark - タップイベントのハンドラ

- (bool) commandListenerRegistered {
    return _commandListeners!=nil;
}

/**
 * Viewへの入力が更新されたときのリスナー登録
 * @param target        listener object
 * @param selector      (cell)->Unit
 * @return key  removeInputListenerに渡して解除する
 */
- (id) addCommandListener:(id)target selector:(SEL)selector {
    if(!self.commandListenerRegistered) {
        if([self.view isKindOfClass:UIButton.class]) {
            [(UIButton*)self.view addTarget:self action:@selector(onButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        } else if([self.view isKindOfClass:MICUiDsCustomButton.class]) {
            [(MICUiDsCustomButton*)self.view setTarget:self action:@selector(onButtonTapped:)];
        }
        _commandListeners = MICListeners.listeners;
    }
    
    return [_commandListeners addListener:(id)target action:selector];
}

/**
* リスナーの登録を解除
*/
- (void)removeCommandListener:(id)key {
    if(nil!=_commandListeners) {
        [_commandListeners removeListener:key];
    }
}

- (void) onButtonTapped:(id)sender {
    if(nil!=_commandListeners) {
        [_commandListeners fire:self];
    }
}

@end
