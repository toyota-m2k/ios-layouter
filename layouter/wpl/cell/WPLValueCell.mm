//
//  WPLValueCell.mm
//  WP Layouter
//
//  Created by toyota-m2k on 2019/08/02.
//  Copyright © 2019 toyota-m2k. All rights reserved.
//

#import "WPLValueCell.h"
#import "MICTargetSelector.h"
#import "MICVar.h"

/**
 * Value属性を持つセルクラス (abstract)
 */
@implementation WPLValueCell {
    NSMutableArray<MICTargetSelector*>* _inputChangedListeners;
}

- (instancetype) initWithView:(UIView*)view
                         name:(NSString*) name
                       margin:(UIEdgeInsets) margin
              requestViewSize:(CGSize) requestViewSize
                   hAlignment:(WPLCellAlignment)hAlignment
                   vAlignment:(WPLCellAlignment)vAlignment
                   visibility:(WPLVisibility)visibility
            containerDelegate:(id<IWPLContainerCellDelegate>)containerDelegate {
    self = [super initWithView:view name:name margin:margin requestViewSize:requestViewSize hAlignment:hAlignment vAlignment:vAlignment visibility:visibility containerDelegate:containerDelegate];
    if(nil!=self) {
        _inputChangedListeners = nil;
    }
    return self;
}

- (void) dispose {
    if(_inputChangedListeners!=nil) {
        [_inputChangedListeners removeAllObjects];
        _inputChangedListeners = nil;
    }
}

/**
 * 値属性
 * please implement in sub-classes
 */
- (id) value {
    [NSException raise:NSInternalInconsistencyException format:@"value property of WPLValueCell: must be overridden."];
    return nil;
}
- (void) setValue:v {
    [NSException raise:NSInternalInconsistencyException format:@"value property of WPLValueCell: must be overridden."];
}

/**
 * Viewへの入力が更新されたときのリスナー登録
 * @param target        listener object
 * @param selector      (cell)->Unit
 * @return key  removeInputListenerに渡して解除する
 */
- (id) addInputChangedListener:(id)target selector:(SEL)selector {
    if(_inputChangedListeners==nil) {
        _inputChangedListeners = [NSMutableArray array];
    }
    
    let key = [[MICTargetSelector alloc] initWithTarget:target selector:selector];
    [_inputChangedListeners addObject:key];
    return key;
}

/**
 * リスナーの登録を解除
 */
- (void) removeInputListener:(id)key {
    if(_inputChangedListeners!=nil) {
        [_inputChangedListeners removeObject:key];
        if(_inputChangedListeners.count==0) {
            _inputChangedListeners = nil;
        }
    }
}

- (void) onValueChanged {
    if(nil!=_inputChangedListeners) {
        for(MICTargetSelector* ts in _inputChangedListeners) {
            id me = self;
            [ts performWithParam:&me];
        }
    }
}
@end
