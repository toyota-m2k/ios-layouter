//
//  WPLObservableData.mm
//  WP Layouter
//
//  Created by Mitsuki Toyota on 2019/08/02.
//  Copyright © 2019 Mitsuki Toyota. All rights reserved.
//

#import "WPLObservableData.h"
#import "MICVar.h"

/**
 * IWPLObservableData の基本実装
 * abstractではないが、valueを変更できないので、
 * 通常は　WPLObservableMutableData, WPLDelegatedObservableData を使い、
 * このクラスを直接使用することはない。
 */
@implementation WPLObservableData {
    NSMutableArray<id<IWPLObservableData>>* _relations;
    NSMutableArray<MICTargetSelector*>* _valueChangedlisteners;
}

- (instancetype) init {
    self = [super init];
    if(self!=nil) {
        _value = NSNull.null;
        _relations = nil;
        _valueChangedlisteners = nil;
    }
    return self;
}

- (void) dispose {
    if(_relations!=nil) {
        [_relations removeAllObjects];
        _relations = nil;
    }
    if(_valueChangedlisteners!=nil) {
        [_valueChangedlisteners removeAllObjects];
        _valueChangedlisteners = nil;
    }
}

- (id) value {
    return _value;
}

- (NSString*) stringValue {
    return (NSString*)_value;
}
- (NSInteger) intValue {
    return [(NSNumber*)_value integerValue];
}

- (CGFloat) floatValue {
    return [(NSNumber*)_value floatValue];
}

- (bool) boolValue {
    return [(NSNumber*)_value boolValue];
}

- (void) valueChanged {
    if(nil!=_valueChangedlisteners && _valueChangedlisteners.count>0) {
        for(MICTargetSelector* ts in _valueChangedlisteners) {
            id me = self;
            [ts performWithParam:&me];
        }
    }
    if(nil!=_relations&&_relations.count>0) {
        for(id<IWPLObservableData> od in _relations) {
            [od valueChanged];
        }
    }
}

/**
 * 値変更が影響する属性のリストに追加
 * @param relation IWPLObservableDataオブジェクト
 */
- (void) addRelation:(id<IWPLObservableData>)relation {
    if(nil==_relations) {
        _relations = [NSMutableArray array];
    }
    [_relations addObject:relation];
}

/**
 * 値変更が影響する属性のリストから削除
 * @param relation IWPLObservableDataオブジェクト
 */
- (void) removeRelation:(id<IWPLObservableData>)relation {
    if(nil!=_relations) {
        [_relations removeObject:relation];
        if(_relations.count==0) {
            _relations = nil;
        }
    }
}

/**
 * 値変更監視リスナーを追加する
 * @param target 通知先
 * @param selector メソッドのセレクタ
 * @return 登録されたリスナーを識別するキー --> removeValueChangedListener に渡して登録解除する
 */
- (id) addValueChangedListener:(id)target selector:(SEL)selector {
    if(nil==_valueChangedlisteners) {
        _valueChangedlisteners = [NSMutableArray array];
    }
    let ts = [[MICTargetSelector alloc] initWithTarget:target selector:selector];
    [_valueChangedlisteners addObject:ts];
    return ts;
}

/**
 * リスナーを登録解除する
 * @param key addValueChangedListener の戻り値
 */
- (void) removeValueChangedListener:(id)key {
    if(nil!=_valueChangedlisteners) {
        [_valueChangedlisteners removeObject:key];
        if(_valueChangedlisteners.count==0) {
            _valueChangedlisteners = nil;
        }
    }
}

@end

