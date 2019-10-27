//
//  WPLGenericBinding.m
//  WP Layouter
//
//  Created by toyota-m2k on 2019/08/05.
//  Copyright © 2019 toyota-m2k. All rights reserved.
//

#import "WPLGenericBinding.h"
#import "WPLCellDef.h"
#import "WPLObservableDef.h"

@implementation WPLGenericBinding {
    id _sourceListenerKey;
}

@synthesize source=_source, cell=_cell, bindingMode=_bindingMode, customAction = _customAction;

- (instancetype)init {
    NSAssert(false, @"don't use default constructor.");
    return nil;
}

/**
 * 標準の初期化
 */
- (instancetype) initWithCell:(id<IWPLCell>)cell
                       source:(id<IWPLObservableData>)source
                  bindingMode:(WPLBindingMode)bindingMode
                 customAction:(WPLBindingCustomAction) customAction {
    return [self initInternalWithCell:cell source:source bindingMode:bindingMode customAction:customAction enableSourceListener:true];
}

/**
 * サブクラスから実行される用の初期化
 * sourceに対する変更監視リスナーの登録遅延が可能。
 */
- (instancetype) initInternalWithCell:(id<IWPLCell>)cell
                               source:(id<IWPLObservableData>)source
                          bindingMode:(WPLBindingMode)bindingMode
                         customAction:(WPLBindingCustomAction) customAction
                 enableSourceListener:(bool) enableSourceListener {
    self = [super init];
    if(nil!=self) {
        _cell = cell;
        _source = source;
        _bindingMode = bindingMode;
        _customAction = customAction;
        _sourceListenerKey = nil;
        if(enableSourceListener) {
            [self startSourceChangeListener];
        }
    }
    return self;
}



- (void)dispose {
    _cell = nil;
    _source = nil;
    _customAction = nil;
    if(nil!=_sourceListenerKey) {
        [self.source removeValueChangedListener:_sourceListenerKey];
        _sourceListenerKey = nil;
    }
}

/**
 * カスタムアクションを呼び出す
 */
- (void) invokeCustomActionFromView:(bool) fromView {
    if(nil!=_customAction) {
        _customAction(self, fromView);
    }
}

/**
 * ソースの変更監視を開始する。
 * initInternalWithCell を enableSourceListener=false で呼び出した場合に、ソース監視を開始するために実行する。
 */
- (void) startSourceChangeListener {
    if(nil==_sourceListenerKey) {
        _sourceListenerKey = [self.source addValueChangedListener:self selector:@selector(onSourceValueChanged:)];
    }
}

/**
 * ソースが変更されたときのイベントハンドラ
 */
- (void) onSourceValueChanged:(id<IWPLObservableData>) source {
    [self invokeCustomActionFromView:false];
}

@end
