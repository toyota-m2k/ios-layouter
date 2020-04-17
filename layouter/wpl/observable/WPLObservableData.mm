//
//  WPLObservableData.mm
//  WP Layouter
//
//  Created by toyota-m2k on 2019/08/02.
//  Copyright © 2019 toyota-m2k. All rights reserved.
//

#import "WPLObservableData.h"
#import "MICVar.h"
#import "MICDicUtil.h"

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
    return nil;
}

- (NSString*) stringValue {
    id v = self.value;
    return [v isKindOfClass:NSString.class] ? (NSString*)v : @"";
}

- (NSInteger) integerValue {
    id v = self.value;
    return [v isKindOfClass:NSNumber.class] ? [(NSNumber*)v integerValue] : 0;
}
- (int) intValue {
    id v = self.value;
    return [v isKindOfClass:NSNumber.class] ? [(NSNumber*)v intValue] : 0;
}

- (double) doubleValue {
    id r = self.value;
    return (nil!=r && [r respondsToSelector:@selector(doubleValue)]) ? [r doubleValue] : 0;
}

- (float) floatValue {
    id r = self.value;
    return (nil!=r && [r respondsToSelector:@selector(floatValue)]) ? [r floatValue] : 0;
}

- (bool) boolValue {
    id v = self.value;
    return [v isKindOfClass:NSNumber.class] ? [(NSNumber*)v boolValue] : false;
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

- (bool) cyclicRelationCheck:(id<IWPLObservableData>)ob {
    if(self == ob) {
        return false;
    }
    if(_relations!=nil) {
        for(id<IWPLObservableData> c in _relations) {
            if(c==ob) {
                return false;
            }
            if(![c cyclicRelationCheck:ob]) {
                return false;
            }
        }
    }
    return true;
}

/**
 * 値変更が影響する属性のリストに追加
 * @param relation IWPLObservableDataオブジェクト
 */
- (void) addRelation:(id<IWPLObservableData>)relation {
#if DEBUG
    if(![self cyclicRelationCheck:relation]) {
        NSAssert(false, @"cyclic relations.");
    }
#endif
    if(nil==_relations) {
        _relations = [NSMutableArray array];
    }
    [_relations addObject:relation];
}

- (void)addRelations:(NSArray<id<IWPLObservableData>> *)relations {
    for(id<IWPLObservableData> ob in relations) {
        [self addRelation:ob];
    }
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

