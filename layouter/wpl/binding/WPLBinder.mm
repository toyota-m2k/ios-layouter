//
//  WPLBinder.m
//  WP Layouter
//
//  Created by toyota-m2k on 2019/08/04.
//  Copyright © 2019 toyota-m2k. All rights reserved.
//

#import "WPLBinder.h"
#import "WPLValueBinding.h"
#import "WPLBoolStateBinding.h"
#import "WPLObservableMutableData.h"
#import "WPLDelegatedObservableData.h"
#import "MICVar.h"

/**
 * Cell と　ObservableData のバインドを管理するクラス。
 */
@implementation WPLBinder {
    NSMutableDictionary<id,id<IWPLObservableData>> * _properties;
    NSMutableArray<id<IWPLBinding>>* _bindings;
}

/**
 * 初期化
 */
- (instancetype) init {
    self = [super init];
    if(self!=nil) {
        _properties = [NSMutableDictionary dictionary];
        _bindings = [NSMutableArray array];
        _autoDisposeProperties = true;
        _autoDisposeBindings = true;
    }
    return self;
}

/**
 * Binding情報を破棄
 */
- (void)dispose {
    if(nil!=_properties) {
        if(self.autoDisposeProperties) {
            for(id key in _properties.allKeys) {
                let prop = [self propertyForKey:key];
                if(nil!=prop) {
                    [prop dispose];
                }
            }
        }
        [_properties removeAllObjects];
        _properties = nil;
    }
    if(nil!=_bindings) {
        if(self.autoDisposeBindings) {
            for(id<IWPLBinding> b in _bindings) {
                [b dispose];
            }
        }
        [_bindings removeAllObjects];
        _bindings = nil;
    }
}

#pragma mark - bindable properties

/**
 * 登録済みのプロパティを取得
 * @param key   createProperty/createDependentProperty の戻り値
 * @return IWPLObservableData型インスタンス（未登録ならnil）
 */
- (id<IWPLObservableData>) propertyForKey:(id)key {
    return _properties[key];
}

/**
 * Observablega*MutableData型のプロパティを取得
 * @param key   createProperty/createDependentProperty の戻り値
 * @return IWPLObservableMutableData型インスタンス（未登録、または、指定されたプロパティがMutableでなければnil）
 */
- (id<IWPLObservableMutableData>) mutablePropertyForKey:(id)key {
    let r = [self propertyForKey:key];
    if([r conformsToProtocol:@protocol(IWPLObservableMutableData)]) {
        return (id<IWPLObservableMutableData>)r;
    } else {
        return nil;
    }
}

/**
 * 通常の値型（ObservableMutableData型）プロパティを作成して登録
 * @param initialValue 初期値
 * @param key プロパティを識別するキー(nilなら、内部で生成して戻り値に返す）。
 * @return プロパティを識別するキー
 */
- (id) createPropertyWithValue:(id)initialValue withKey:(id) key {
    let ov = [WPLObservableMutableData new];
    ov.value = initialValue;
    return [self addProperty:ov forKey:key];
}

/**
 * 依存型(DelegatedObservableData型）プロパティを生成して登録
 * @param key プロパティを識別するキー（nilなら内部で生成して戻り値に返す）。
 * @param sourceProc 値を解決するための関数ブロック
 * @param relations このプロパティが依存するプロパティ（のキー）。。。このメソッドが呼び出される時点で解決できなければ、指定は無効となるので、定義順序に注意。
 */
- (id) createDependentPropertyWithKey:(id)key sourceProc:(WPLSourceDelegateProc)sourceProc dependsOn:(id)relations, ... {
    let ov = [WPLDelegatedObservableData newDataWithSourceBlock:sourceProc];
    va_list args;
    va_start(args, relations);
    [self createDependentPropertyWithKey:key sourceProc:sourceProc dependsOn:relations dependsOnArgument:args];
    va_end(args);
    return [self addProperty:ov forKey:key];
}

/**
 * 上のメソッドの可変長引数部分をva_list型引数で渡せるようにしたメソッド
 */
- (id) createDependentPropertyWithKey:(id)key sourceProc:(WPLSourceDelegateProc)sourceProc dependsOn:(NSString*) firstRelation dependsOnArgument:(va_list) args {
    let ov = [WPLDelegatedObservableData newDataWithSourceBlock:sourceProc];
    id rel = firstRelation;
    while(rel!=nil) {
        let ovr = _properties[rel];
        if(ovr!=nil) {
            [ovr addRelation:ov];
        }
        rel = va_arg(args, id);
    }
    return [self addProperty:ov forKey:key];
}

/**
 * 外部で作成したObservableData型のインスタンスをプロパティとしてバインダーに登録する。
 * @param prop ObservableData型インスタンス
 * @param key プロパティを識別するキー（nilなら内部で生成して戻り値に返す）。
 */
- (id) addProperty:(id<IWPLObservableData>) prop forKey:(id) key {
    if(key==nil) {
        key = prop;
    }
    [_properties setObject:prop forKey:key];
    return key;
}

/**
 * プロパティをバインダーから削除する。
 * @param key   addProperty, createProperty / createDependentProperty などが返した値。
 */
- (void) removeProperty:(id)key {
    if(self.autoDisposeProperties) {
        let prop = [self propertyForKey:key];
        if(nil!=prop){
            [prop dispose];
        }
    }
    [_properties removeObjectForKey:key];
}

#pragma mark - binding properties with cells

/**
 * 外部で作成したバインディングインスタンスを登録する。
 * @param binding   バインディングインスタンス
 */
- (void) addBinding:(id<IWPLBinding>) binding {
    [_bindings addObject:binding];
}

/**
 * セルの値とプロパティのバインディングを作成して登録
 * @param propKey   バインドするプロパティを識別するキー（必ず登録済みのものを指定）
 * @param cell      バインドするセル
 * @param bindingMode   VIEW_TO_SOURCE_WITH_INIT | VIEW_TO_SOURCE | SOURCE_TO_VIEW | TWOWAY
 * @param customAction  プロパティ、または、セルの値が変更されたときのコールバック関数（nil可）
 */
- (id<IWPLBinding>) bindProperty:(id)propKey
                 withValueOfCell:(id<IWPLCell>)cell
                     bindingMode:(WPLBindingMode)bindingMode
                     customActin:(WPLBindingCustomAction)customAction {
    let prop = [self propertyForKey:propKey];
    if(nil==prop) {
        NSAssert(false, @"no property %@", [propKey description]);
        return nil;
    }
    let binding = [[WPLValueBinding alloc] initWithCell:cell source:prop bindingMode:bindingMode customAction:customAction];
    [self addBinding:binding];
    return binding;
}

/**
 * セルの状態(Bool型）とプロパティのバインディングを作成して登録
 * @param propKey       バインドするプロパティを識別するキー（必ず登録済みのものを指定）
 * @param cell          バインドするセル
 * @param actionType    Cellの何とバインドするか？
 * @param negation      trueにすると、bool値を反転する
 * @param customAction  プロパティ、または、セルの値が変更されたときのコールバック関数（nil可）
 */
- (id<IWPLBinding>) bindProperty:(id)propKey
             withBoolStateOfCell:(id<IWPLCell>)cell
                      actionType:(WPLBoolStateActionType) actionType
                        negation:(bool) negation
                     customActin:(WPLBindingCustomAction)customAction {
    let prop = [self propertyForKey:propKey];
    if(nil==prop) {
        NSAssert(false, @"no property %@", [propKey description]);
        return nil;
    }
    let binding = [[WPLBoolStateBinding alloc] initWithCell:cell source:prop customAction:customAction actionType:actionType negation:negation];
    [self addBinding:binding];
    return binding;
}

/**
 * 特殊なバインドを作成　（SOURCE to VIEWのみ）
 * バインドの内容は、customAction に記述する。
 * （ソースが変更されると、customAction が呼び出されるので、そこでなんでも好きなことをするのだ）
 */
- (id<IWPLBinding>) bindProperty:(id)propKey
                        withCell:(id<IWPLCell>)cell
                    customAction:(WPLBindingCustomAction) customAction {
    let prop = [self propertyForKey:propKey];
    if(nil==prop) {
        NSAssert(false, @"no property %@", [propKey description]);
        return nil;
    }
    let binding = [[WPLGenericBinding alloc] initWithCell:cell source:prop bindingMode:WPLBindingModeSOURCE_TO_VIEW customAction:customAction];
    [self addBinding:binding];
    return binding;
}

/**
 * バインドを解除する
 * @param binding   バインディングインスタンス
 */
- (void) unbind:(id<IWPLBinding>) binding {
    NSInteger i = [_bindings indexOfObject:binding];
    if(i != NSNotFound) {
        if(self.autoDisposeBindings) {
            [binding dispose];
        }
        [_bindings removeObjectAtIndex:i];
    }
}

@end
