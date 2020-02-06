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
    MICListeners* _tappedListeners;
}

#pragma mark - 初期化・解放

- (instancetype) initWithView:(UIView*)view
                         name:(NSString*) name
                       margin:(UIEdgeInsets) margin
              requestViewSize:(CGSize) requestViewSize
                   hAlignment:(WPLCellAlignment)hAlignment
                   vAlignment:(WPLCellAlignment)vAlignment
                   visibility:(WPLVisibility)visibility
            containerDelegate:(id<IWPLContainerCellDelegate>)containerDelegate {
    self = [super initWithView:view name:name margin:margin requestViewSize:requestViewSize hAlignment:hAlignment vAlignment:vAlignment visibility:visibility containerDelegate:nil];
    if(self!=nil) {
        _tappedListeners = nil;
    }
    return self;
}

- (void) dispose {
    if(nil!=_tappedListeners) {
        [_tappedListeners removeAll];
        _tappedListeners = nil;
    }
}

#pragma mark - タップイベントのハンドラ

- (bool) tappedListenerRegistered {
    return _tappedListeners!=nil;
}

/**
 * Viewへの入力が更新されたときのリスナー登録
 * @param target        listener object
 * @param selector      (cell)->Unit
 * @return key  removeInputListenerに渡して解除する
 */
- (id) addTappedListener:(id)target selector:(SEL)selector {
    if(!self.tappedListenerRegistered) {
        if([self.view isKindOfClass:UIButton.class]) {
            [(UIButton*)self.view addTarget:self action:@selector(onButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        } else if([self.view isKindOfClass:MICUiDsCustomButton.class]) {
            [(MICUiDsCustomButton*)self.view setTarget:self action:@selector(onButtonTapped:)];
        }
        _tappedListeners = MICListeners.listeners;
    }
    
    return [_tappedListeners addListener:(id)target action:selector];
}

/**
* リスナーの登録を解除
*/
- (void)removeTappedListener:(id)key {
    if(nil!=_tappedListeners) {
        [_tappedListeners removeListener:key];
    }
}

- (void) onButtonTapped:(id)sender {
    if(nil!=_tappedListeners) {
        [_tappedListeners fire:self];
    }
}

@end
